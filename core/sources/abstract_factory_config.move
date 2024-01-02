module sui_intf_demo_core::abstract_factory_config {
    use std::type_name::{Self, TypeName};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::vec_set::{Self, VecSet};

    friend sui_intf_demo_core::int_supplier;
    friend sui_intf_demo_core::int_consumer;

    const ENotAdmin: u64 = 100;
    const ENotAllowedImpl: u64 = 101;

    struct AbstractFactoryConfig has key, store {
        id: UID,
        impl_allowlist: VecSet<TypeName>,
    }

    struct AbstractFactoryConfigCap has key, store {
        id: UID,
        for: ID
    }

    fun init(ctx: &mut TxContext) {
        let config = AbstractFactoryConfig {
            id: object::new(ctx),
            impl_allowlist: vec_set::empty(),
        };
        let cap = AbstractFactoryConfigCap {
            id: object::new(ctx),
            for: object::id(&config),
        };
        sui::transfer::transfer(cap, tx_context::sender(ctx));
        sui::transfer::share_object(config);
    }

    public fun add_allowed_impl<WT>(config: &mut AbstractFactoryConfig, cap: &AbstractFactoryConfigCap) {
        assert!(has_access(config, cap), ENotAdmin);
        let type_name = type_name::get<WT>();
        if (!vec_set::contains(&config.impl_allowlist, &type_name)) {
            vec_set::insert(&mut config.impl_allowlist, type_name);
        };
    }

    public fun remove_allowed_impl<WT>(config: &mut AbstractFactoryConfig, cap: &AbstractFactoryConfigCap) {
        assert!(has_access(config, cap), ENotAdmin);
        let type_name = type_name::get<WT>();
        if (vec_set::contains(&config.impl_allowlist, &type_name)) {
            vec_set::remove(&mut config.impl_allowlist, &type_name);
        };
    }

    public(friend) fun assert_allowlisted<WT: drop>(config: &AbstractFactoryConfig, _impl_witness: WT) {
        assert!(vec_set::contains(&config.impl_allowlist, &type_name::get<WT>()), ENotAllowedImpl);
    }

    /// Check whether the ConfigCap matches the Config.
    public fun has_access(config: &mut AbstractFactoryConfig, cap: &AbstractFactoryConfigCap): bool {
        object::id(config) == cap.for
    }
}

