module sui_intf_demo_core::demo_service_process {
    use sui_intf_demo_core::binary_operator;

    // public fun foo(x: u64, y: u64): u64 {
    //     let (x_1, y_1) = foo_step_0(x, y);
    //     let r_1 = binary_operator_1::apply(x_1, y_1);
    //     let r_2 = binary_operator_2::apply(y_1, r_1);
    //     foo_step_3(r_2)
    // }

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

    public fun foo(//<Op_1: drop>(
        //_impl_witness_1: Op_1,
        x: u64,
        y: u64
    ): binary_operator::ApplyRequest<FooStep_1Context>
    {
        let (x_1, y_1) = foo_step_0(x, y);
        let step_1_context = FooStep_1Context {
            x,
            y,
            x_1,
            y_1,
        };
        let step_1_request = binary_operator::new_apply_request(
            //_impl_witness_1,
            x_1,
            y_1,
            step_1_context,
        );
        step_1_request
    }

    public fun foo_step_1_callback<Op_1>(
        //_impl_witness_1: Op_1,
        //_impl_witness_2: Op_2,
        //step_1_request: binary_operator::ApplyRequest<Op_1>,
        step_1_response: binary_operator::ApplyResponse<Op_1, FooStep_1Context>,
        //step_1_context: FooStep_1Context,
    ): binary_operator::ApplyRequest<FooStep_2Context>
    {
        let (r_1, step_1_request) = binary_operator::unpack_apply_respone(step_1_response);
        //binary_operator::drop_apply_request(step_1_request);
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
        let step_2_request = binary_operator::new_apply_request<FooStep_2Context>(//_impl_witness_2, 
            y_1, 
            r_1,
            step_2_context,
        );
        step_2_request
    }

    #[allow(unused_assignment)]
    public fun foo_step_2_callback<Op_2>(
        //_impl_witness_2: Op_2,
        //step_2_request: binary_operator::ApplyRequest<Op_2>,
        step_2_response: binary_operator::ApplyResponse<Op_2, FooStep_2Context>,
        //step_2_context: FooStep_2Context,
    ): u64 {
        let (r_2, step_2_request) = binary_operator::unpack_apply_respone(step_2_response);
        //binary_operator::drop_apply_request(step_2_request);
        let (_, _, step_2_context) = binary_operator::unpack_apply_request(step_2_request);
        let FooStep_2Context {
            x,
            y,
            x_1,
            y_1,
            r_1
        } = step_2_context;
        foo_step_3(r_2)
    }

    fun foo_step_0(x: u64, y: u64): (u64, u64) {
        (x + 1, y + 1)
    }

    fun foo_step_3(v: u64): u64 {
        v + 1
    }

}