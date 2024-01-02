module sui_intf_demo_core::int_supplier {
    use sui_intf_demo_core::abstract_factory_config::{Self, AbstractFactoryConfig};

    struct GetRequest<C> {
        _get_context: C,
    }

    struct GetResponse<phantom WT, C> {
        result: u64,
        _get_request: GetRequest<C>,
    }

    public(friend) fun new_get_request<C>(
        _get_context: C,
    ): GetRequest<C> {
        GetRequest {
            _get_context,
        }
    }

    #[allow(unused_variable)]
    public fun get_get_request_all_parameters<C>(request: &GetRequest<C>) {
        
    }

    public(friend) fun unpack_get_request<C>(
        _get_request: GetRequest<C>,
    ): C {
        let GetRequest {
            _get_context,
        } = _get_request;
        _get_context
    }

    public fun new_get_response<WT: drop, C>(
        config: &AbstractFactoryConfig,
        _impl_witness: WT,
        result: u64,
        _get_request: GetRequest<C>,
    ): GetResponse<WT, C> {
        abstract_factory_config::assert_allowlisted(config, _impl_witness);
        GetResponse {
            result,
            _get_request,
        }
    }

    public(friend) fun unpack_get_respone<WT, C>(
        _get_response: GetResponse<WT, C>,
    ): (u64, GetRequest<C>) {
        let GetResponse {
            result,
            _get_request,
        } = _get_response;
        (result, _get_request)
    }

}
//
// The boilerplate code that implements the interface:
//
/*
module xxx_package_id::xxx_int_supplier_impl {
    use sui_intf_demo_core::int_supplier::{Self, IntSupplierConfig};

    struct XxxIntSupplierImpl has drop {}

    public fun get<C>(config: &IntSupplierConfig, get_request: int_supplier::GetRequest<C>): int_supplier::GetResponse<XxxIntSupplierImpl, C> {
        let  = int_supplier::get_get_request_all_parameters(&get_request);
        //todo let result: u64 = ...
        int_supplier::new_get_response(
            config,
            XxxIntSupplierImpl{},
            result,
            get_request
        )
    }

}
*/