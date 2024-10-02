defmodule Supermarket.SupermarketRepository do
  use GenServer
  @table_name :supermarket_db

  def start_link(_param) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_args) do
    create_ets_table()
    {:ok, nil}
  end

  def create_ets_table do
    :ets.new(@table_name, [:bag, :protected, :named_table, read_concurrency: true])
  end

  def get_sale_by_document_id(document_number) do
    GenServer.call(__MODULE__, {:get_sale_by_document_id, document_number})
  end

  def get_sale_by_amount(amount_initial, amount_final, document_id) do
    GenServer.call(__MODULE__, {:get_sale_by_amount, amount_initial, amount_final, document_id})
  end

  def insert_sale(request_data) do
    GenServer.cast(__MODULE__, {:insert_sale, request_data})
  end

  def update_client_name(request_data) do
    GenServer.cast(__MODULE__, {:update_client_name, request_data})
  end


  def delete_sale(document_id) do
    GenServer.cast(__MODULE__, {:delete_sale, document_id})
  end

  def get_sale_by_product_id(product_id, document_id) do
    GenServer.call(__MODULE__, {:get_sale_by_product_id, product_id, document_id})
  end

  def handle_cast({:insert_sale, {identifier, sale}}, _state) do
    :ets.insert(@table_name, {String.to_atom(identifier), sale})
    {:noreply, :ok}
  end

  def handle_cast({:delete_sale, document_id}, _state) do
    :ets.delete(@table_name, String.to_atom(document_id))
    {:noreply, :ok}
  end

  def handle_cast({:update_client_name, {document_id, client_name_new}}, _state) do
    case :ets.lookup(@table_name, String.to_atom(document_id)) do
      [] ->
        {:noreply, :ok}

      sales_response ->
        :ets.delete(@table_name, String.to_atom(document_id))

        sales_response
        |> Enum.map(fn {_, sale} ->
          new_sale = Map.put(sale, :client_name, client_name_new)
          :ets.insert(@table_name, {String.to_atom(document_id), new_sale})
        end)

        {:noreply, :ok}
    end
  end

  def handle_call({:get_sale_by_document_id, document_number}, _from, _state) do
    case :ets.lookup(@table_name, String.to_atom(document_number)) do
      [] -> {:reply, nil, :ok}
      sales_response -> {:reply, sales_response, :ok}
    end
  end

  def handle_call({:get_sale_by_amount, amount_initial, amount_final, document_id}, _from, _state) do
    match_spec = [
      {{:"$1", %{amount: :"$2"}},
       [
         {:andalso, {:==, :"$1", String.to_atom(document_id)}},
         {:andalso, {:>=, :"$2", amount_initial}},
         {:andalso, {:"=<", :"$2", amount_final}}
       ], [:"$_"]}
    ]

    case :ets.select(@table_name, match_spec) do
      [] -> {:reply, [], :ok}
      sales_response -> {:reply, sales_response, :ok}
    end
  end

  def handle_call({:get_sale_by_product_id, product_id, document_id}, _from, _state) do
    match_spec = [
      {{:"$1", %{product_id: :"$2"}},
       [
         {:andalso, {:==, :"$1", String.to_atom(document_id)}},
         {:andalso, {:==, :"$2", product_id}}
       ], [:"$_"]}
    ]

    case :ets.select(@table_name, match_spec) do
      [] -> {:reply, [], :ok}
      sales_response -> {:reply, sales_response, :ok}
    end
  end
end
