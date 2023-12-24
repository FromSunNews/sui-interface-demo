module sui_intf_demo_impl::addition_operator {
    use sui_intf_demo_core::binary_operator::{Self, BinaryOperatorConfig};

    struct AdditionOperator has drop {}

    public fun apply<C>(config: &BinaryOperatorConfig, apply_request: binary_operator::ApplyRequest<C>): binary_operator::ApplyResponse<AdditionOperator, C> {
        let (first, second) = binary_operator::get_apply_request_all_parameters(&apply_request);
        let result: u64 = first + second;
        binary_operator::new_apply_response(
            config,
            AdditionOperator{},
            result,
            apply_request
        )
    }

}