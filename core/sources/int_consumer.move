module sui_intf_demo_core::int_consumer {
    use sui_intf_demo_core::abstract_factory_config::{Self, AbstractFactoryConfig};

    struct AcceptRequest<C> {
        value: u64,
        _accept_context: C,
    }

    struct AcceptResponse<phantom WT, C> {
        _accept_request: AcceptRequest<C>,
    }

    public(friend) fun new_accept_request<C>(
        value: u64,
        _accept_context: C,
    ): AcceptRequest<C> {
        AcceptRequest {
            value,
            _accept_context,
        }
    }

    public fun get_accept_request_all_parameters<C>(request: &AcceptRequest<C>): u64 {
        request.value
    }

    public(friend) fun unpack_accept_request<C>(
        _accept_request: AcceptRequest<C>,
    ): (u64, C) {
        let AcceptRequest {
            value,
            _accept_context,
        } = _accept_request;
        (value, _accept_context)
    }

    public fun new_accept_response<WT: drop, C>(
        config: &AbstractFactoryConfig,
        _impl_witness: WT,
        _accept_request: AcceptRequest<C>,
    ): AcceptResponse<WT, C> {
        abstract_factory_config::assert_allowlisted(config, _impl_witness);
        AcceptResponse {
            _accept_request,
        }
    }

    public(friend) fun unpack_accept_respone<WT, C>(
        _accept_response: AcceptResponse<WT, C>,
    ): AcceptRequest<C> {
        let AcceptResponse {
            _accept_request,
        } = _accept_response;
        _accept_request
    }

}
//
// The boilerplate code that implements the interface:
//
/*
module xxx_package_id::xxx_int_consumer_impl {
    use sui_intf_demo_core::int_consumer::{Self, IntConsumerConfig};

    struct XxxIntConsumerImpl has drop {}

    public fun accept<C>(config: &IntConsumerConfig, accept_request: int_consumer::AcceptRequest<C>): int_consumer::AcceptResponse<XxxIntConsumerImpl, C> {
        let value = int_consumer::get_accept_request_all_parameters(&accept_request);
        int_consumer::new_accept_response(
            config,
            XxxIntConsumerImpl{},
            accept_request
        )
    }

}
*/
