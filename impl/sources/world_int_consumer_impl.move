#[allow(unused_use, unused_assignment)]
module sui_intf_demo_impl::world_int_consumer_impl {
    use sui_intf_demo_core::abstract_factory_config::{Self, AbstractFactoryConfig};
    use sui_intf_demo_core::int_consumer;

    struct WorldIntConsumerImpl has drop {}

    public fun accept<C>(config: &AbstractFactoryConfig, accept_request: int_consumer::AcceptRequest<C>): int_consumer::AcceptResponse<WorldIntConsumerImpl, C> {
        let value = int_consumer::get_accept_request_all_parameters(&accept_request);
        int_consumer::new_accept_response(
            config,
            WorldIntConsumerImpl{},
            accept_request
        )
    }

}
