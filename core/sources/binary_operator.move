module sui_intf_demo_core::binary_operator {
    use sui::tx_context::TxContext;

    friend sui_intf_demo_core::demo_service_process;

    struct BINARY_OPERATOR has drop {}

    fun init(_witness: BINARY_OPERATOR, _ctx: &mut TxContext) {
    }

    //public fun apply(first: u64, second: u64) : u64 {
    //}

    struct ApplyRequest<C> {//<phantom T> {
        first: u64,
        second: u64,
        _apply_context: C,
    }

    struct ApplyResponse<phantom WT, C> {
        result: u64,
        _apply_request: ApplyRequest<C>,
    }

    public(friend) fun new_apply_request<C>(//<ImplW: drop>(
        //_impl_witness: ImplW,
        first: u64, 
        second: u64,
        _apply_context: C,
    ): ApplyRequest<C> {//<ImplW> {
        ApplyRequest {
            first,
            second,
            _apply_context,
        }
    }

    // public fun apply_request_first(request: &ApplyRequest): u64 {
    //     request.first
    // }

    // public fun apply_request_second(request: &ApplyRequest): u64 {
    //     request.second
    // }

    public fun get_apply_request_all_parameters<C>(request: &ApplyRequest<C>): (u64, u64) {
        (request.first, request.second)
    }

    // public(friend) fun drop_apply_request(//<ImplW>(
    //     _apply_request: ApplyRequest, //<ImplW>,
    // ) {
    //     let ApplyRequest {
    //         first: _,
    //         second: _,
    //     } = _apply_request;
    // }

    public(friend) fun unpack_apply_request<C>(//<ImplW>(
        _apply_request: ApplyRequest<C>, //<ImplW>,
    ): (u64, u64, C) {
        let ApplyRequest {
            first,
            second,
            _apply_context,
        } = _apply_request;
        (first, second, _apply_context)
    }

    public fun new_apply_response<WT: drop, C>(
        _impl_witness: WT,
        result: u64,
        _apply_request: ApplyRequest<C>,
    ): ApplyResponse<WT, C> {
        ApplyResponse {
            result,
            _apply_request,
        }
    }

    public(friend) fun unpack_apply_respone<WT, C>(
        _apply_response: ApplyResponse<WT, C>,
    ): (u64, ApplyRequest<C>) {
        let ApplyResponse {
            result,
            _apply_request,
        } = _apply_response;
        (result, _apply_request)
    }

}