defmodule BE.DbConnectionPool do
  @moduledoc """
  Super simple connection pool - just a list of connections.
  No queueing, just fails if no connections available.
  """
  use GenServer

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get_connection do
    GenServer.call(__MODULE__, :get_connection)
  end

  def return_connection(conn) do
    GenServer.cast(__MODULE__, {:return_connection, conn})
  end

  @impl true
  def init(_opts) do
    pool_size = 3

    db_config = [
      hostname: "localhost",
      username: "postgres",
      password: "admin",
      database: "elixirdb",
      port: 5555
    ]

    IO.puts("Creating #{pool_size} database connections...")

    connections =
      1..pool_size
      |> Enum.map(fn i ->
        IO.puts("Connection #{i}")
        {:ok, pid} = Postgrex.start_link(db_config)
        pid
      end)

    # State is just a list of available connections
    {:ok, connections}
  end

  @impl true
  def handle_call(:get_connection, _from, []) do
    {:reply, {:error, :no_connections}, []}
  end

  @impl true
  def handle_call(:get_connection, _from, [conn | rest]) do
    IO.puts("Giving out connection #{inspect(conn)}")
    {:reply, {:ok, conn}, rest}
  end

  @impl true
  def handle_cast({:return_connection, conn}, connections) do
    IO.puts("Got connection #{inspect(conn)} back")
    {:noreply, [conn | connections]}
  end
end
