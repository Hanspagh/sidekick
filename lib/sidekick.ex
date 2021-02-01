defmodule Sidekick do
  @moduledoc """
  Documentation for `Sidekick`.
  """

  def start(name \\ :docker, host \\ '127.0.0.1') do
    sidekick_node = :"#{name}@#{host}"
    parent_node = Node.self()
    wait_for_sidekick(sidekick_node, parent_node)
  end

  def call(name \\ :docker, host \\ '127.0.0.1', module, method, args) do
    :rpc.block_call(:"#{name}@#{host}", module, method, args)
  end

  def cast(name \\ :docker, host \\ '127.0.0.1', module, method, args) do
    :rpc.cast(:"#{name}@#{host}", module, method, args)
  end

  defp wait_for_sidekick(sidekick_node, parent_node) do
    :net_kernel.monitor_nodes(true)
    command = mk_command(sidekick_node, parent_node)
    Port.open({:spawn, command}, [:stream])

    receive do
      {:nodeup, ^sidekick_node} ->
        {:ok, sidekick_node}
    after
      5000 ->
        # Shutdown node if we never received a response
        Node.spawn(sidekick_node, :init, :stop, [])
        {:error, :timeout}
    end
  end

  defp mk_command(sidekick_node, parent_node) do
    {:ok, command} = :init.get_argument(:progname)
    paths = Enum.join(:code.get_path(), " , ")

    base_args = "-noinput -name #{sidekick_node}"

    priv_dir = :code.priv_dir(:sidekick)
    boot_file_args = "-boot #{priv_dir}/node"

    cookie = Node.get_cookie()
    cookie_arg = "-setcookie #{cookie}"

    paths_arg = "-pa #{paths}"

    command_args = "-s Elixir.Sidekick start_sidekick #{parent_node}"

    args = "#{base_args} #{boot_file_args} #{cookie_arg} #{paths_arg} #{command_args}"

    "#{command} #{args}"
  end

  def start_sidekick([parent_node]) do
    Node.monitor(parent_node, true)
    #TODO Here we can start any kind of process, we just require a start and clean_up method
    Sidekick.Docker.start()
    receive do
      {:nodedown, _node} ->
        Sidekick.Docker.clean_up()
        :init.stop()
    end
  end
end
