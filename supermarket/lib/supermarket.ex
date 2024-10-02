defmodule Supermarket do
  alias Supermarket.SupermarketRepository
  def insert_sale(document_number, document_type, client_name, product_name, amount, phone) do
    SupermarketRepository.insert_sale(
      {document_type <> "_" <> document_number,
       build_sale_structure(client_name, product_name, amount, phone)}
    )
  end

  def delete_sale(document_number, document_type) do
    SupermarketRepository.delete_sale(document_type <> "_" <> document_number)
    :ok
  end

  def update_client_name(document_number, document_type, client_name_new) do
    SupermarketRepository.update_client_name(
      {document_type <> "_" <> document_number, client_name_new}
    )

    :ok
  end

  def get_sale_by_document_id(document_number, document_type) do
    SupermarketRepository.get_sale_by_document_id(document_type <> "_" <> document_number)
    |> Enum.map(fn response ->
      case is_nil(response) do
        true -> []
        _ -> {_, sale} = response
             sale
      end
    end)
  end

  def get_sale_by_product_id(document_number, document_type, product_id) do
    SupermarketRepository.get_sale_by_product_id(
      product_id,
      document_type <> "_" <> document_number
    )
    |> Enum.map(fn response ->
      case is_nil(response) do
        true ->
          []

        _ ->
          {_, sale} = response
          sale
      end
    end)
  end

  def get_sale_by_amount(document_number, document_type, amount_initial, amount_final) do
    response =
      SupermarketRepository.get_sale_by_amount(
        amount_initial,
        amount_final,
        document_type <> "_" <> document_number
      )

    if Enum.empty?(response) do
      response
    else
      Enum.map(response, fn {_, sale} -> sale end)
    end
  end

  defp build_sale_structure(client_name, product_name, amount, phone) do
    %{
      client_name: client_name,
      product_name: product_name,
      product_id: generate_product_id(),
      amount: amount,
      phone: phone
    }
  end

  defp generate_product_id() do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end
end

