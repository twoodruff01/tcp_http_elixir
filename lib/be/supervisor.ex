defmodule BE.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {BE.Connector, 4000},
      {DynamicSupervisor, name: BE.SessionSupervisor},
      {BE.Api, name: BE.Api}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
