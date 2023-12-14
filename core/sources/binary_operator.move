module sui_intf_demo_core::binary_operator {
    use sui::tx_context::TxContext;

    friend sui_intf_demo_core::demo_service_process;

    struct BINARY_OPERATOR has drop {}

    fun init(_witness: BINARY_OPERATOR, _ctx: &mut TxContext) {
    }

    //public fun apply(first: u64, second: u64) : u64 {
    //}

    struct ApplyRequest {//<phantom T> {
        first: u64,
        second: u64,
    }

    struct ApplyResponse<phantom T> {
        result: u64,
        _appply_request: ApplyRequest,
    }

    public fun new_apply_request(//<ImplW: drop>(
        //_impl_witness: ImplW,
        first: u64, 
        second: u64,
    ): ApplyRequest {//<ImplW> {
        ApplyRequest {
            first,
            second,
        }
    }

    // public fun apply_request_first(request: &ApplyRequest): u64 {
    //     request.first
    // }

    // public fun apply_request_second(request: &ApplyRequest): u64 {
    //     request.second
    // }

    public fun get_apply_request_all_parameters(request: &ApplyRequest): (u64, u64) {
        (request.first, request.second)
    }

    // public(friend) fun drop_apply_request(//<ImplW>(
    //     _appply_request: ApplyRequest, //<ImplW>,
    // ) {
    //     let ApplyRequest {
    //         first: _,
    //         second: _,
    //     } = _appply_request;
    // }

    public(friend) fun unpack_apply_request(//<ImplW>(
        _appply_request: ApplyRequest, //<ImplW>,
    ): (u64, u64) {
        let ApplyRequest {
            first,
            second,
        } = _appply_request;
        (first, second)
    }

    public fun new_apply_response<ImplW: drop>(
        _impl_witness: ImplW,
        result: u64,
        _appply_request: ApplyRequest,
    ): ApplyResponse<ImplW> {
        ApplyResponse {
            result,
            _appply_request,
        }
    }

    public(friend) fun unpack_apply_respone<ImplW>(
        _appply_response: ApplyResponse<ImplW>,
    ): (u64, ApplyRequest) {
        let ApplyResponse {
            result,
            _appply_request,
        } = _appply_response;
        (result, _appply_request)
    }

}