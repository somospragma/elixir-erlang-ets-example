defmodule Supermarket.Application do
  use Application
  alias Supermarket.SupermarketRepository
  @impl true
  def start(_type, _args) do
    children = [
      {SupermarketRepository, []}
    ]

    opts = [strategy: :one_for_one, name: Supermarket.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
