#[allow(unused_use, unused_assignment)]
module sui_intf_demo_impl::hello_int_supplier_impl {
    use sui_intf_demo_core::abstract_factory_config::{Self, AbstractFactoryConfig};
    use sui_intf_demo_core::int_supplier;

    struct HelloIntSupplierImpl has drop {}

    public fun get<C>(config: &AbstractFactoryConfig, get_request: int_supplier::GetRequest<C>): int_supplier::GetResponse<HelloIntSupplierImpl, C> {
        //let _ = int_supplier::get_get_request_all_parameters(&get_request);
        let result: u64 = 1;
        int_supplier::new_get_response(
            config,
            HelloIntSupplierImpl{},
            result,
            get_request
        )
    }
}
