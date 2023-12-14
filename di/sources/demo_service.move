module sui_intf_demo_di::demo_service {
    //use sui::tx_context::TxContext;
    use sui_intf_demo_core::demo_service_process;
    use sui_intf_demo_impl::addition_operator as op_1;
    use sui_intf_demo_impl::multiplication_operator as op_2;


    public fun foo(//<Op_1, Op_2>(
        x: u64,
        y: u64
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

        let (req_1, c_1) = demo_service_process::foo(x, y);
        let rsp_1 = op_1::apply(req_1);
        let (req_2, c_2) = demo_service_process::foo_step_1_callback(rsp_1, c_1);
        let rsp_2 = op_2::apply(req_2);
        demo_service_process::foo_step_2_callback(rsp_2, c_2)
    }

    
}
