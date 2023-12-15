module sui_intf_demo_core::binary_operator {
    use std::type_name::{Self, TypeName};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};
    use sui::object::{Self, ID, UID};
    
    friend sui_intf_demo_core::demo_service_process;

    const ENotAdmin: u64 = 100;
    const ENotAllowedImpl: u64 = 101;

    struct BINARY_OPERATOR has drop {}

    struct BinaryOperatorConfig has key, store {
        id: UID,
        impl_allowlist: VecSet<TypeName>,
    }

    struct BinaryOperatorConfigCap has key, store {
        id: UID,
        for: ID
    }

    fun init(_witness: BINARY_OPERATOR, ctx: &mut TxContext) {
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

    /// Check whether the `BinaryOperatorConfigCap` matches the `BinaryOperatorConfig`.
    public fun has_access(config: &mut BinaryOperatorConfig, cap: &BinaryOperatorConfigCap): bool {
        object::id(config) == cap.for
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