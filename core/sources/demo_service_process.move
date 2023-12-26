module sui_intf_demo_core::demo_service_process {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::binary_operator;

    struct FooStep_1Context {
        x: u64,
        y: u64,
        x_1: u64,
        y_1: u64,
    }

    struct FooStep_2Context {
        x: u64,
        y: u64,
        x_1: u64,
        y_1: u64,
        r_1: u64,
    }

    public fun foo(
        x: u64,
        y: u64,
        _ctx: &TxContext,
    ): binary_operator::ApplyRequest<FooStep_1Context> {
        let (x_1, y_1) = foo_step_0(x, y, _ctx);
        let step_1_context = FooStep_1Context {
            x,
            y,
            x_1,
            y_1,
        };
        let step_1_request = binary_operator::new_apply_request<FooStep_1Context>(
            x_1,
            y_1,
            step_1_context,
        );
        step_1_request
    }

    public fun foo_step_1_callback<Op_1>(
        step_1_response: binary_operator::ApplyResponse<Op_1, FooStep_1Context>,
        _ctx: &TxContext,
    ): binary_operator::ApplyRequest<FooStep_2Context> {
        let (r_1, step_1_request) = binary_operator::unpack_apply_respone(step_1_response);
        let (_, _, step_1_context) = binary_operator::unpack_apply_request(step_1_request);
        let FooStep_1Context {
            x,
            y,
            x_1,
            y_1,
        } = step_1_context;
        let step_2_context = FooStep_2Context {
            x,
            y,
            x_1,
            y_1,
            r_1,
        };
        let step_2_request = binary_operator::new_apply_request<FooStep_2Context>(
            y_1,
            r_1,
            step_2_context,
        );
        step_2_request
    }

    #[allow(unused_assignment)]
    public fun foo_step_2_callback<Op_2>(
        step_2_response: binary_operator::ApplyResponse<Op_2, FooStep_2Context>,
        _ctx: &TxContext,
    ): u64 {
        let (r_2, step_2_request) = binary_operator::unpack_apply_respone(step_2_response);
        let (_, _, step_2_context) = binary_operator::unpack_apply_request(step_2_request);
        let FooStep_2Context {
            x,
            y,
            x_1,
            y_1,
            r_1,
        } = step_2_context;
        foo_step_3(r_2, _ctx)
    }

    fun foo_step_0(
        x: u64,
        y: u64,
        _ctx: &TxContext,
    ): (u64, u64) {
        (x + 1, y + 1)
    }

    fun foo_step_3(
        v: u64,
        _ctx: &TxContext,
    ): u64 {
        v + 1
    }

}
//
// The boilerplate code that does "Dependency Injection".
//
/*
module xxx_di_package_id::demo_service {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::demo_service_process;
    use sui_intf_demo_core::binary_operator::BinaryOperatorConfig;
    use op_1_impl_package_id::op_1_binary_operator_impl as op_1;
    use op_2_impl_package_id::op_2_binary_operator_impl as op_2;

    public fun foo(
        _binary_operator_config: &BinaryOperatorConfig,
        x: u64,
        y: u64,
        _ctx: &TxContext,
    ): u64 {
        let step_1_req = demo_service_process::foo(x, y, _ctx);
        let step_1_rsp = op_1::apply(_binary_operator_config, step_1_req);
        let step_2_req = demo_service_process::foo_step_1_callback(step_1_rsp, _ctx);
        let step_2_rsp = op_2::apply(_binary_operator_config, step_2_req);
        demo_service_process::foo_step_2_callback(step_2_rsp, _ctx)
    }

}
*/
