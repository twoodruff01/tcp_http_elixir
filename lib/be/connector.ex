defmodule BE.Connector do
  @moduledoc """
  `Connector` interacts with new clients once, when they first contact the system.
  It passes the socket connection for each new connection to the `SessionSupervisor`.
  """
  use Task

  def start_link(port) do
    Task.start_link(__MODULE__, :start, [port])
  end

  def start(port) do
    opts = [:binary, active: false, packet: :raw, reuseaddr: true]

    case :gen_tcp.listen(port, opts) do
      {:ok, socket} ->
        listen(socket)

      {:error, error} ->
        IO.puts("Error starting #{__MODULE__}: #{error}")
        error
    end
  end

  defp listen(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = DynamicSupervisor.start_child(BE.SessionSupervisor, {BE.Connection, client})
    :ok = :gen_tcp.controlling_process(client, pid)
    BE.Connection.begin(pid)
    listen(socket)
  end
end
