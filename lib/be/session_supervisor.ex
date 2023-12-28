# defmodule BE.SessionSupervisor do
#   @moduledoc """
#   `SessionManager` supervises connections and their sessions.
#   If a connection dies, don't restart it.
#   """
#   use DynamicSupervisor
# end

# @impl true
# def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
#   # 6. Delete from the ETS table instead of the map
#   {name, refs} = Map.pop(refs, ref)
#   :ets.delete(names, name)
#   {:noreply, {names, refs}}
# end
