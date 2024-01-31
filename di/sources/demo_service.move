module sui_intf_demo_di::demo_service {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::demo_service_process;
    use sui_intf_demo_core::binary_operator::BinaryOperatorConfig;
    use sui_intf_demo_impl::addition_operator as op_1;
    use sui_intf_demo_impl::multiplication_operator as op_2;

    public fun foo(
        _binary_operator_config: &BinaryOperatorConfig,
        x: u64,
        y: u64,
        _ctx: &mut TxContext,
    ): u64 {
        let step_1_req = demo_service_process::foo(x, y, _ctx);
        let step_1_rsp = op_1::apply(_binary_operator_config, step_1_req);
        let step_2_req = demo_service_process::foo_step_1_callback(step_1_rsp, _ctx);
        let step_2_rsp = op_2::apply(_binary_operator_config, step_2_req);
        demo_service_process::foo_step_2_callback(step_2_rsp, _ctx)
    }


    struct FooEvent has copy, drop {
        result: u64,
    }

    public entry fun test_foo(
        _config: &BinaryOperatorConfig,
        _ctx: &mut TxContext,
    ) {
        let x = 1;
        let y = 2;
        let rsp = foo(_config, x, y, _ctx);
        sui::event::emit(FooEvent { result: rsp });
    }
    //
    // sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::addition_operator::AdditionOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000
    // sui client call --function add_allowed_impl --module binary_operator --package 0x89ffe07a3defcb50d0546a07c698907942e235a8d8ab6a2e3b639cfb1963e260 --type-args '0x17bdcf146e12ce862aeda56524468595f38a95e278900ac34842124ddbc7b5f7::multiplication_operator::MultiplicationOperator' --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e 0x289747bafc8b879f84933ca808972120d61d25226ffd38e4eb1cc6e6a5761a8b --gas-budget 1000000000
    //
    // sui client call --function test_foo --module demo_service --package _CURRENT_PCK_ID_ --args 0x6b341e0ee34d5a833cca5e7d094dce21424bc6aa39c8d914af2cb93846e5a30e --gas-budget 1000000000
    //
    // (2 + 3) * 3 + 1 = 16
    //

}
