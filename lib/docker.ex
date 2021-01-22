defmodule Sidekick.Docker do
  use GenServer

  def start() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    Node.monitor(:"test@127.0.0.1", true)
    {:ok, {}}
  end

  def state() do
    :sys.get_state(__MODULE__)
  end

  def handle_info({:nodedown, node}, _state) do
    IO.inspect("Closing #{Node.self} down because #{node} went down")
    :init.stop()
  end

end
