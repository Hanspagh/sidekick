defmodule Sidekick do
  @moduledoc """
  Documentation for `Sidekick`.
  """

  def start(name \\ :docker) do
    paths = :code.get_path
    :sidekick.start('127.0.0.1', name, paths)
  end


  def call(node \\ :docker, module, method, args) do
    :rpc.block_call(:"#{node}@127.0.0.1", module, method, args)
  end

end
