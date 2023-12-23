module sui_intf_demo_core::demo_service_process {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::binary_operator;

    // --------------- Pseudo-code Start ---------------
    /*
    public interface binary_operator {
        fun apply(first: u64, second: u64) : u64;
    }

    @inject
    private op_1: binary_operator;

    @inject
    private op_2: binary_operator;

    public fun foo(x: u64, y: u64): u64 {
        let (x_1, y_1) = foo_step_0(x, y); //<- step_0
        let r_1 = binary_operator_1::apply(x_1, y_1); //<- step_1
        let r_2 = binary_operator_2::apply(y_1, r_1); //<- step_2
        foo_step_3(r_2) //<- step_3
    }

    fun foo_step_0(x: u64, y: u64): (u64, u64) {
        //...
    }

    fun foo_step_3(v: u64): u64 {
        //...
    }
    */
    // --------------- Pseudo-code End --------------- 

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
