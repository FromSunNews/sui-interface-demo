# Dependency Injection for Move Contracts with dddappp

English | [中文版](./README_CN.md)

Developers who have developed Java applications should be familiar with the Spring Framework, 
one of whose core features is "dependency injection" (DI). 
One of the benefits of dependency injection is that it decouples the components of an application, 
making it easier to maintain and extend.

Dependency injection is actually a practice of the "inversion of control (IoC)" programming idea. 
IoC is a necessary weapon in the mindset of developing large-scale applications. (On this issue, do not intend to expand the discussion here 😄.)


## If Move has "interface" ...

There must be a lot of developers out there who expect the Move language to someday have interface-like features 
(maybe it's not called `interface`, it's called `trait` or something else) and then implement dependency injection based on it.
What they probably expect is to be able to write Move contracts like the following (pseudo-code):

```move
module sui_intf_demo::demo_service {
    /// Define an interface
    public interface binary_operator {
        fun apply(first: u64, second: u64) : u64;
    }

    #[inject] // <- means that need to inject a component that implements the binary_operator interface.
    private op_1: binary_operator;

    #[inject] // <- means that need to inject another component that implements the binary_operator interface.
    private op_2: binary_operator;

    public fun foo(x: u64, y: u64): u64 {
        let (x_1, y_1) = foo_step_0(x, y); //<- step_0
        let r_1 = op_1::apply(x_1, y_1); //<- step_1, call the function of component op_1
        let r_2 = op_2::apply(y_1, r_1); //<- step_2, Call the function of component op_2
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

Then, they want to be able to inject two components that implement the `binary_operator` 
interface into the above `demo_service` somewhere with some "configuration code".

Obviously, at this point in time, Move contracts **can't** be written like this. 
The biggest obstacle is that Move does not currently have the `interface` feature. 
However, it is possible to implement something similar based on the existing Move features with a few tricks.

If you have prior knowledge of Move's ["hot potato"](http://examples.sui.io/patterns/hot-potato.html) pattern, 
it should help you to understand the relevant code of the solution described below.

## Using dddappp to implement "Dependency Injection"

Now, let's use dddappp, the efficiency killer, and just show you the code.
Otherwise, if you want to manually code the following solution, it might be a bit of a pain in the ass. 😂

### Writing DDDML model file

Let's take the pseudo-code above as an example and "translate" it into a DDDML model file:

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

It should be noted that, according to the DDDML convention, the various "identifiers", 
including the names of `services`, `methods`, and `parameters`, should be named using the `PascalCase` naming style.
This allows them to be visually distinguished from DDDML `camelCase` keywords (e.g. `methods`, `parameters`, etc.).


### "Writing" the core model code of Move contract

For this step, you don't actually need to write any more code, just run the dddappp CLI like this (assuming the model file above is saved in `. /dddml/services.yaml`):

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

Then a Move project is generated in the `core` directory. You can see that it contains two files:

* `binary_operator.move`: this contains the definition of the `binary_operator` interface on which the service depends.
* `demo_service_process.move`: this is the service that depends on the `binary_operator` interface".
    In its comments, we can find that it also thoughtfully provides boilerplate code 
    that shows how to inject the service with the implementations of the interface on which it depends.

Aha, you see that the definition of the interface is also placed in the item called `core`, which stands for core model, right?
That's right, following the idea of IoC, the "stuff" on which the execution of an application depends are part of the "core model" of the domain.

### Implementing the interface

Let's create a Move project in the `impl` directory. Then write two implementations of the `binary_operator` interface in it ...

### Injecting dependencies

In the `di` directory, we have created a Move project that demonstrates how to implement dependency injection.

For illustrative purposes, in this project we "wrap a service" based on the "core model" project and the "interface implementation" project:

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

Actually, I think this is not necessary for Sui Move.
We could perhaps consider using Sui's [Programmable Transaction Blocks](https://docs.sui.io/concepts/transactions/prog-txn-blocks) feature 
to implement "injections" on the "front end".


## Testing

We need to realize that when a service depends on an injected "external component" to accomplish a function, the external component must be "safe".
The code generated by dddappp provides the basic "security management" mechanism.

The following commands add two implementations of the interface to the allowlist that can be called by the "core business logic":

```shell
sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::addition_operator::AdditionOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000

sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::multiplication_operator::MultiplicationOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000 
```

You can then test it by calling one of the test functions in the `di` project contract like this to see the output of the CLI:

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
