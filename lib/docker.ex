defmodule Sidekick.Docker do
  use GenServer

  def start([parent_node, waiter]) do
    IO.inspect("Starting Gen server")
    send({waiter, parent_node}, {self(), :slave_started})
    GenServer.start_link(__MODULE__, [parent_node], name: __MODULE__)
  end

  def init([node]) do
    Node.monitor(node, true)
    {:ok, {node}}
  end

  def state() do
    :sys.get_state(__MODULE__)
  end

  def handle_info({:nodedown, _node}, _state) do
    :init.stop()
  end

end
