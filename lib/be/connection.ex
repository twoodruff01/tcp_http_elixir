defmodule BE.Connection do
  @moduledoc """
  I don't particularly feel like writing a fully-fledged http client, so
  this is a rather hacky way of just getting something working.
  """
  use GenServer, restart: :transient

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  def begin(pid) do
    GenServer.cast(pid, :transfer)
  end

  @impl true
  def handle_cast(:transfer, socket) do
    # transfer(socket)
    transfer_v2(socket)
    {:stop, :shutdown, {}}
  end

  def transfer_v2(socket) do
    # This implementation expects the entire HTTP request to be readable from the socket in one go.
    # max_length = 8000
    set_protocol = "HTTP/1.1"
    crlf = "\r\n"

    case :gen_tcp.recv(socket, 0) do
      {:ok, req} ->
        if String.valid?(req) do
          IO.puts("Exact: #{req}")
          lines = String.split(req, crlf)
          [header | rest] = lines
          # GET /here HTTP/1.1
          [method, target, protocol] = String.split(header, " ")

          if protocol != set_protocol do
            raise "#{protocol} not supported, please use #{set_protocol}"
          end

          if method != "GET" do
            raise "#{method} method not implemented"
          end

          # GET /here HTTP/1.1\r\nkey: value\r\nanotherKey: anotherValue\r\n\r\ncontent is amazing how good is it.
          # headers stop after two consequtive crlf
          headers =
            Enum.take_while(rest, &(&1 != ""))
            |> Enum.map(&List.to_tuple(String.split(&1, ": ")))
            |> Enum.into(%{})

          ["" | content] = Enum.drop_while(rest, &(&1 != ""))

          IO.puts(method)
          IO.puts(target)
          IO.puts(protocol)
          IO.inspect(headers)
          IO.puts(content)

          result = BE.Api.receive(BE.Api, {:GET, target})
          response = add_headers(result)
          :gen_tcp.send(socket, response)

          :gen_tcp.close(socket)

          transfer_v2(socket)
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
        "\r\n"
      ) <> "\r\n" <> "\r\n" <> str

    IO.puts(res)
    res
  end

  @impl true
  def init(socket) do
    {:ok, socket}
  end
end
