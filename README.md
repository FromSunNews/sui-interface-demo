# 使用 dddappp 实现 Move 合约的依赖注入

写过 Java 应用的开发者，应该很熟悉 Spring 框架。Spring 框架的核心功能之一就是依赖注入。依赖注入的好处之一是，可以将应用程序的各个组件解耦，从而使得应用程序更容易维护和扩展。

依赖注入其实是“控制反转”编程思想的实践。而控制反转，是开发大规模应用必备的思维武器。（关于这个问题，这里不打算展开讨论。😄）


## 如果 Move 有“接口”……

一定有很多人期望 Move 语言有朝一日具备类似其他语言的 interface 特性，然后基于 interface 实现依赖注入。可能他们期望的是，可以类似下面这样编写 Move 合约（伪代码）：

```move
module sui_intf_demo::demo_service {
    /// 定义一个接口
    public interface binary_operator {
        fun apply(first: u64, second: u64) : u64;
    }

    #[inject] // <- 表示这里需要注入一个实现 binary_operator 接口的组件
    private op_1: binary_operator;

    #[inject] // <- 表示这里需要注入另一个实现 binary_operator 接口的组件
    private op_2: binary_operator;

    public fun foo(x: u64, y: u64): u64 {
        let (x_1, y_1) = foo_step_0(x, y); //<- step_0
        let r_1 = op_1::apply(x_1, y_1); //<- step_1，调用组件 op_1 的函数
        let r_2 = op_2::apply(y_1, r_1); //<- step_2，调用组件 op_2 的函数
        foo_step_3(r_2) //<- step_3
    }

    fun foo_step_0(x: u64, y: u64): (u64, u64) {
        (x + 1, y + 1)
    }

    fun foo_step_3(v: u64): u64 {
        v + 1
    }
}
```

然后，我们希望可以在“某个地方”，通过一些“配置代码”，为上面的 `demo_service` 注入两个实现了 `binary_operator` 接口的组件。

显然，目前 Move 合约并**不能**像上面这样写。最大的障碍是 Move 目前没有 interface 特性。不过，我们确实可以通过一些技巧，在现有的 Move 特性的基础上实现类似的功能。

如果你想要手动编码来实现这个过程，可能还是挺“麻烦”的；这时候你应该需要 dddappp 这个效率提升的大杀器。😄


## 使用 dddappp 实现 Move 合约的“依赖注入”

### 编写 DDDML 模型文件

我们以上面的伪代码为示例，将它“直译”为 DDDML 的模型文件：

```yaml
services:
  BinaryOperator:
    abstract: true
    methods:
      Apply:
        parameters:
          First:
            type: u64
          Second:
            type: u64
        result:
          type: u64
  DemoService:
    requiredComponents:
      Op_1:
        type: BinaryOperator
      Op_2:
        type: BinaryOperator
    methods:
      Foo:
        parameters:
          X:
            type: u64
          Y:
            type: u64
        result:
          type: u64
        steps:
          Step_0:
            invokeLocal: "FooStep_0"
            arguments:
              X: X
              Y: Y
            exportVariables:
              X_1:
              Y_1:
          Step_1:
            invokeParticipant: "Op_1.Apply"
            arguments:
              First: X_1
              Second: Y_1
            exportVariable: R_1
          Step_2:
            invokeParticipant: "Op_2.Apply"
            arguments:
              First: Y_1
              Second: R_1
            exportVariable: R_2
          Step_3:
            invokeLocal: "FooStep_3"
            arguments:
              V: R_2
      FooStep_0:
        isInternal: true
        parameters:
          X:
            type: u64
          Y:
            type: u64
        result:
          tupleItems:
            - type: u64
            - type: u64
        implementLogic:
          Move:
            "(x + 1, y + 1)"
      FooStep_3:
        isInternal: true
        parameters:
          V:
            type: u64
        result:
          type: u64
        implementLogic:
          Move:
            "v + 1"
```

我们需要注意一下，按照 DDDML 的规范，各种“标识符”，包括“服务”、方法、参数的名字，应该使用 `PascalCase` 命名风格，这让它们可以很好地与 DDDML 的“关键字”在视觉上区分开来。


### “编写” Move 合约的核心模型代码

事实上你不需要再编写什么代码，只需要这样执行一下 dddappp CLI（假设上面的模型文件保存在 `./dddml/services.yaml`）：

```shell
docker run \
-v .:/myapp \
wubuku/dddappp:0.0.1 \
--dddmlDirectoryPath /myapp/dddml \
--boundedContextName Test.SuiInterfaceDemo \
--suiMoveProjectDirectoryPath /myapp/core \
--boundedContextSuiPackageName sui_intf_demo_core \
--boundedContextJavaPackageName org.test.suiinterfacedemo \
--javaProjectsDirectoryPath /myapp/sui-java-service \
--javaProjectNamePrefix suiinterfacedemo \
--pomGroupId test.suiinterfacedemo
```

然后在 `core` 目录会生成一个 Move 项目。你可以看到其中包含了两个文件：

* `binary_operator.move`。这里主要包含了我们要实现的服务所依赖的“接口”的定义。在它的注释中，我们可以发现它还贴心地提供了如何实现这个接口的样板代码。
* `demo_service_process.move`。这是一个依赖于“接口”的服务。在它的注释中，我们可以发现它还贴心地提供了如何为这个服务注入它所依赖的“接口的实现”的样板代码。

哈，你看到接口的定义也放到了这个名为 `core`（表示核心模型）的项目中了，对吧？ 
没错，按照控制反转的思想，一个应用执行所依赖的外部接口，是领域的“核心模型”的一部分。

### 实现接口

让我们在 `impl` 目录，创建了一个 Move 项目。然后在里面编写 `binary_operator` 接口的两个实现……

### 注入依赖

在 `di` 目录，我们创建了一个 Move 项目，演示了如何实现“依赖注入”。

为了便于说明问题，在这个项目中，我们基于“核心模型”以及“接口实现”两个项目的合约，“包装”出一个“服务”，即：

```move
    public fun foo(
        _binary_operator_config: &BinaryOperatorConfig,
        x: u64,
        y: u64,
        _ctx: &TxContext,
    ): u64 {
        //...
    }
```

实际上，对于 Sui Move 来说，我觉得这个做法不是必须的。
我们可以也许可以考虑使用 Sui 的 [Programmable Transaction Blocks](https://docs.sui.io/concepts/transactions/prog-txn-blocks) 特性来在“前端”实现“注入”。

## 测试

我们需要意识到：当一个“服务”需要依赖注入的“外部组件”来完成某个功能，这个外部组件必须是“安全的”。
dddappp 生成的代码提供了基础的“管理”机制。

下面的命令展示的是，将两个接口的实现添加到可以被“核心业务逻辑”调用的 allowlist（即所谓的“白名单”） 中：

```shell
sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::addition_operator::AdditionOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000

sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::multiplication_operator::MultiplicationOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000 
```

然后，你可以类似下面这样调用 `di` 项目合约中的一个测试函数进行测试，查看 CLI 的输出：

```shell
sui client call --function test_foo --module demo_service --package {DI_PACKAGE_ID} \
--args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e \
--gas-budget 1000000000
```

## Some Tips

### Clean Up Exited Docker Containers

Run the command:

```shell
docker rm $(docker ps -aq --filter "ancestor=wubuku/dddappp:0.0.1")
```

### A More Complex Sui Demo

If you are interested, you can find a more complex Sui Demo here: ["A Sui Demo"](https://github.com/dddappp/A-Sui-Demo).
