module sui_intf_demo_di::demo_service {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::demo_service_process;
    use sui_intf_demo_impl::addition_operator as op_1;
    use sui_intf_demo_impl::multiplication_operator as op_2;


    public fun foo(//<Op_1, Op_2>(
        x: u64,
        y: u64,
        _ctx: &TxContext,
    ): u64 {
        // let (req_1, c_1) = demo_service_process::foo(x, y);
        // //let (another_req_1, another_c_1) = demo_service_process::foo(x, y);
        // let rsp_1 = op_1::apply(req_1);
        // //let another_rsp_1 = op_1::apply(another_req_1);
        // let (req_2, c_2) = demo_service_process::foo_step_1_callback(rsp_1, c_1);
        // //let (req_2, c_2) = demo_service_process::foo_step_1_callback(rsp_1, another_c_1);
        // //let (another_req_2, another_c_2) = demo_service_process::foo_step_1_callback(another_rsp_1, c_1);
        // let rsp_2 = op_2::apply(req_2);
        // //let another_rsp_2 = op_2::apply(another_req_2);
        // //demo_service_process::foo_step_2_callback(another_rsp_2, another_c_2);
        // demo_service_process::foo_step_2_callback(rsp_2, c_2)

        let step_1_req = demo_service_process::foo(x, y, _ctx);
        let step_1_rsp = op_1::apply(step_1_req);
        let step_2_req = demo_service_process::foo_step_1_callback(step_1_rsp, _ctx);
        let step_2_rsp = op_2::apply(step_2_req);
        demo_service_process::foo_step_2_callback(step_2_rsp, _ctx)
    }

    struct FooEvent has copy, drop {
        result: u64,
    }

    public entry fun test_foo(
        _ctx: &TxContext,
    ) {
        let x = 1;
        let y = 2;
        let rsp = foo(x, y, _ctx);
        sui::event::emit(FooEvent { result: rsp });
    } 
    //
    // sui client call --function test_foo --module demo_service --package __PCK_ID_ --gas-budget 1000000000
    //
    // (2 + 3) * 3 + 1 = 16
    //

}
