module sui_intf_demo_core::binary_operator {
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    friend sui_intf_demo_core::demo_service_process;

    const ENotAdmin: u64 = 100;
    const ENotAllowedImpl: u64 = 101;

    struct BinaryOperatorConfig has key, store {
        id: UID,
        impl_allowlist: VecSet<TypeName>,
    }

    struct BinaryOperatorConfigCap has key, store {
        id: UID,
        for: ID
    }

    fun init(ctx: &mut TxContext) {
        let config = BinaryOperatorConfig {
            id: object::new(ctx),
            impl_allowlist: vec_set::empty(),
        };
        let cap = BinaryOperatorConfigCap {
            id: object::new(ctx),
            for: object::id(&config),
        };
        sui::transfer::transfer(cap, tx_context::sender(ctx));
        sui::transfer::share_object(config);
    }

    public fun add_allowed_impl<WT>(config: &mut BinaryOperatorConfig, cap: &BinaryOperatorConfigCap) {
        assert!(has_access(config, cap), ENotAdmin);
        let type_name = type_name::get<WT>();
        if (!vec_set::contains(&config.impl_allowlist, &type_name)) {
            vec_set::insert(&mut config.impl_allowlist, type_name);
        };
    }

    public fun remove_allowed_impl<WT>(config: &mut BinaryOperatorConfig, cap: &BinaryOperatorConfigCap) {
        assert!(has_access(config, cap), ENotAdmin);
        let type_name = type_name::get<WT>();
        if (vec_set::contains(&config.impl_allowlist, &type_name)) {
            vec_set::remove(&mut config.impl_allowlist, &type_name);
        };
    }

    /// Check whether the ConfigCap matches the Config.
    public fun has_access(config: &mut BinaryOperatorConfig, cap: &BinaryOperatorConfigCap): bool {
        object::id(config) == cap.for
    }

    struct ApplyRequest<C> {
        first: u64,
        second: u64,
        _apply_context: C,
    }

    struct ApplyResponse<phantom WT, C> {
        result: u64,
        _apply_request: ApplyRequest<C>,
    }

    public(friend) fun new_apply_request<C>(
        first: u64,
        second: u64,
        _apply_context: C,
    ): ApplyRequest<C> {
        ApplyRequest {
            first,
            second,
            _apply_context,
        }
    }

    public fun get_apply_request_all_parameters<C>(request: &ApplyRequest<C>): (u64, u64) {
        (request.first, request.second)
    }

    public(friend) fun unpack_apply_request<C>(
        _apply_request: ApplyRequest<C>,
    ): (u64, u64, C) {
        let ApplyRequest {
            first,
            second,
            _apply_context,
        } = _apply_request;
        (first, second, _apply_context)
    }

    public fun new_apply_response<WT: drop, C>(
        config: &BinaryOperatorConfig,
        _impl_witness: WT,
        result: u64,
        _apply_request: ApplyRequest<C>,
    ): ApplyResponse<WT, C> {
        assert!(vec_set::contains(&config.impl_allowlist, &type_name::get<WT>()), ENotAllowedImpl);
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
//
// The boilerplate code that implements the interface:
//
/*
module xxx_package_id::xxx_binary_operator_impl {
    use sui_intf_demo_core::binary_operator::{Self, BinaryOperatorConfig};

    struct XxxBinaryOperatorImpl has drop {}

    public fun apply<C>(config: &BinaryOperatorConfig, apply_request: binary_operator::ApplyRequest<C>): binary_operator::ApplyResponse<XxxBinaryOperatorImpl, C> {
        let (first, second) = binary_operator::get_apply_request_all_parameters(&apply_request);
        //todo let result: u64 = ...
        binary_operator::new_apply_response(
            config,
            XxxBinaryOperatorImpl{},
            result,
            apply_request
        )
    }

}
*/
