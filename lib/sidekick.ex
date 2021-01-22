defmodule Sidekick do
  @moduledoc """
  Documentation for `Sidekick`.
  """

  def start() do
    {:ok, node} =  :slave.start('127.0.0.1', :docker)
    load_paths()
    call(:docker, Sidekick.Docker, :start, [])
    {:ok, node}
  end

  defp load_paths() do
    call(:docker, :code, :add_paths, [:code.get_path])
  end

  def test_shutdown() do
    call(:test, :init, :stop, [])
  end

  def call(node, module, method, args) do
    :rpc.block_call(:"#{node}@127.0.0.1", module, method, args)
  end

end
