module sui_intf_demo_core::hello_world_service_process {
    use sui::object;
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::int_consumer;
    use sui_intf_demo_core::int_supplier;

    const EMismatchedObjectId: u64 = 10;

    struct FooSupplyContext {
    }

    struct FooConsumeContext {
        r: u64,
    }

    public fun foo(
        _ctx: &mut TxContext,
    ): int_supplier::GetRequest<FooSupplyContext> {
        let supply_context = FooSupplyContext {
        };
        let supply_request = int_supplier::new_get_request<FooSupplyContext>(
            supply_context,
        );
        supply_request
    }

    public fun foo_supply_callback<Supplier>(
        supply_response: int_supplier::GetResponse<Supplier, FooSupplyContext>,
        _ctx: &mut TxContext,
    ): int_consumer::AcceptRequest<FooConsumeContext> {
        let (r, supply_request) = int_supplier::unpack_get_respone(supply_response);
        let supply_context = int_supplier::unpack_get_request(supply_request);
        let FooSupplyContext {
        } = supply_context;
        let consume_context = FooConsumeContext {
            r,
        };
        let consume_request = int_consumer::new_accept_request<FooConsumeContext>(
            r,
            consume_context,
        );
        consume_request
    }

    #[allow(unused_assignment)]
    public fun foo_consume_callback<Consumer>(
        consume_response: int_consumer::AcceptResponse<Consumer, FooConsumeContext>,
        _ctx: &mut TxContext,
    ) {
        let consume_request = int_consumer::unpack_accept_respone(consume_response);
        let (_, consume_context) = int_consumer::unpack_accept_request(consume_request);
        let FooConsumeContext {
            r,
        } = consume_context;
    }

}
//
// The boilerplate code that does "Dependency Injection".
//
/*
module xxx_di_package_id::hello_world_service {
    use sui::tx_context::TxContext;
    use sui_intf_demo_core::hello_world_service_process;
    use sui_intf_demo_core::abstract_factory_config::AbstractFactoryConfig;
    use supplier_impl_package_id::supplier_int_supplier_impl as supplier;
    use consumer_impl_package_id::consumer_int_consumer_impl as consumer;

    public fun foo(
        _abstract_factory_config: &AbstractFactoryConfig,
        _ctx: &TxContext,
    ) {
        let supply_req = hello_world_service_process::foo(_ctx);
        let supply_rsp = supplier::get(_abstract_factory_config, supply_req);
        let consume_req = hello_world_service_process::foo_supply_callback(supply_rsp, _ctx);
        let consume_rsp = consumer::accept(_abstract_factory_config, consume_req);
        hello_world_service_process::foo_consume_callback(consume_rsp, _ctx)
    }

}
*/
