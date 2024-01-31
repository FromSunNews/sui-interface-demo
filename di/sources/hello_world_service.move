module sui_intf_demo_di::hello_world_service {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::hello_world_service_process;
    use sui_intf_demo_core::abstract_factory_config::AbstractFactoryConfig;
    use sui_intf_demo_impl::hello_int_supplier_impl as supplier;
    use sui_intf_demo_impl::world_int_consumer_impl as consumer;

    public fun foo(
        _abstract_factory_config: &AbstractFactoryConfig,
        _ctx: &mut TxContext,
    ) {
        let supply_req = hello_world_service_process::foo(_ctx);
        let supply_rsp = supplier::get(_abstract_factory_config, supply_req);
        let consume_req = hello_world_service_process::foo_supply_callback(supply_rsp, _ctx);
        let consume_rsp = consumer::accept(_abstract_factory_config, consume_req);
        hello_world_service_process::foo_consume_callback(consume_rsp, _ctx)
    }

}
