defmodule BE.RequestHandler do
  @moduledoc """
  If you turned this into a fully fledged framework, this would be where you'd
  handle different methods individually.
  """

  @supported_protocol "HTTP/1.1"

  def handle_request({_method, _url, protocol}) when protocol != @supported_protocol do
    raise "#{protocol} not supported, please use #{@supported_protocol}"
  end

  def handle_request({"GET", url, @supported_protocol}) do
    IO.puts("begin processing GET #{url}")
    process_get_request(url)
  end

  def handle_request({"POST", _url, @supported_protocol}) do
    raise "POST method not implemented"
  end

  def handle_request({"PUT", _url, @supported_protocol}) do
    raise "PUT method not implemented"
  end

  def handle_request({"PATCH", _url, @supported_protocol}) do
    raise "PATCH method not implemented"
  end

  def handle_request({method, _url, @supported_protocol}) do
    raise "#{method} method not supported"
  end

  defp process_get_request(url) do
    # This will crash if there aren't enough connections, that's fine :)
    # There are lots of other ways of dealing with exhausted connection pool, as a learning exercise...
    {:ok, conn} = BE.DbConnectionPool.get_connection()
    IO.puts("got connection #{inspect(conn)} from pool")

    try do
      Postgrex.query!(
        conn,
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
        conn,
        ~c"INSERT INTO requests (request, method, create_timestamp) VALUES ('#{url}', 'GET', current_timestamp);",
        []
      )

      IO.puts("wait 5 seconds to simulate work")
      Process.sleep(5000)

      "#{String.reverse(url)}\r\n"
    after
      IO.puts("returning connection #{inspect(conn)} to pool")
      BE.DbConnectionPool.return_connection(conn)
    end
  end
end
