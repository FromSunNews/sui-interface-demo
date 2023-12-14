module sui_intf_demo_impl::addition_operator {
    //use sui::tx_context::TxContext;
    use sui_intf_demo_core::binary_operator;

    struct AdditionOperator has drop {}

    public fun apply(appply_request: binary_operator::ApplyRequest): binary_operator::ApplyResponse<AdditionOperator> {
        //let first = binary_operator::apply_request_first(&appply_request);
        //let second = binary_operator::apply_request_second(&appply_request);
        let (first, second) = binary_operator::get_apply_request_all_parameters(&appply_request);
        //let w = AdditionOperator{};
        binary_operator::new_apply_response(AdditionOperator{}, first + second, appply_request)
    }
}