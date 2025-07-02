defmodule BE.Session do
  @moduledoc """
  A very simple HTTP client which reads bytes, processes them, and responds.
  """
  use GenServer, restart: :temporary

  @crlf "\r\n"

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def begin(pid) do
    GenServer.cast(pid, :transfer)
  end

  @impl true
  def handle_cast(:transfer, socket) do
    transfer(socket)
    {:stop, :shutdown, {}}
  end

  def transfer(socket) do
    # This implementation expects the entire HTTP request to be readable from the socket in one go.

    case :gen_tcp.recv(socket, 0) do
      {:ok, req} ->
        if String.valid?(req) do
          lines = String.split(req, @crlf)
          [header | _] = lines
          # header should look like this: GET /here HTTP/1.1
          header
          |> String.split(" ")
          |> List.to_tuple()
          |> BE.RequestHandler.handle_request()
          |> tap(&IO.puts("response: #{&1}"))
          |> add_headers()
          |> then(&:gen_tcp.send(socket, &1))

          :gen_tcp.close(socket)
        else
          # Ctrl-c in Telnet sends non utf-8 input...
          IO.puts("nasty non utf-8 request, stopping transfer()")
        end

      {:error, reason} ->
        IO.puts("transfer() stopped, reason: #{reason}")
    end
  end

  def add_headers(str) do
    res =
      Enum.join(
        [
          "HTTP/1.1 200 OK",
          "Accept-Ranges: bytes",
          "Cache-Control: max-age=604800",
          "Content-Type: text/html; charset=UTF-8",
          "Date: #{DateFormatter.to_rfc822(DateTime.utc_now())}",
          "Content-Length: #{String.length(str)}",
          "Connection: close"
          # "Content-Type: application/json; charset=UTF-8",
        ],
        @crlf
      ) <> @crlf <> @crlf <> str

    res
  end

  @impl true
  def init(socket) do
    {:ok, socket}
  end
end
