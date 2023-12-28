defmodule BE.Api do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, {}, opts)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def receive(server, req) do
    case req do
      {:GET, data} ->
        GenServer.call(server, {:GET, data})

      {:POST, _} ->
        {:error, "NOT IMPLEMENTED"}

      {:PUT, _} ->
        {:error, "NOT IMPLEMENTED"}
    end
  end

  @impl true
  def handle_call({:GET, path}, _from, _) do
    IO.puts("processing: #{path}")

    {:ok, pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres",
        port: "5444"
      )

    Postgrex.query!(
      pid,
      ~c"CREATE TABLE IF NOT EXISTS public.requests
         (
           id SERIAL PRIMARY KEY,
           request VARCHAR(300),
           method VARCHAR(10),
           create_timestamp timestamp without time zone NOT NULL
         );",
      []
    )

    # Classic SQL injection vulnerability, which doesn't matter on a toy project...
    Postgrex.query!(
      pid,
      ~c"INSERT INTO requests (request, method, create_timestamp) VALUES ('#{path}', 'GET', current_timestamp);",
      []
    )

    {:reply, "#{String.reverse(path)}\r\n", {}}
  end
end
