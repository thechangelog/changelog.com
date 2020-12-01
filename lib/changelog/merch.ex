defmodule Changelog.Merch do
  alias Shopify.PriceRule
  alias Shopify.PriceRule.DiscountCode

  @doc """
  Creates and returns a Shopify discount code
  """
  def create_discount(code, value) do
    session = Shopify.session()

    new_rule = %PriceRule{
      title: code,
      value: value,
      starts_at: Timex.now(),
      allocation_method: "across",
      customer_selection: "all",
      target_selection: "all",
      target_type: "line_item",
      usage_limit: 1,
      value_type: "fixed_amount"
    }

    new_code = %DiscountCode{code: code}

    with {:ok, %{data: %{id: id}}} <- PriceRule.create(session, new_rule),
         {:ok, %{data: dc}} <- DiscountCode.create(session, id, new_code),
         do: {:ok, dc}
  end
end
