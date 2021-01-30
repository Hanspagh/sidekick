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
    waiter_register = :sidekick_waiter
    Process.register(self(), waiter_register)

    command = mk_command(sidekick_node, parent_node, waiter_register)
    Port.open({:spawn, command}, [:stream])

    receive do
      {sidekick_pid, :started} ->
        Process.unregister(waiter_register)
        {:ok, sidekick_pid}
    after
      5000 ->
        # Shutdown node if we never received a response
        Node.spawn(sidekick_node, :init, :stop, [])
        {:error, :timeout}
    end
  end

  defp mk_command(sidekick_node, parent_node, waiter_register) do
    {:ok, command} = :init.get_argument(:progname)
    paths = Enum.join(:code.get_path(), " , ")

    base_args = "-noinput -name #{sidekick_node}"

    priv_dir = :code.priv_dir(:sidekick)
    boot_file_args = "-boot #{priv_dir}/node"

    release_cookie = System.get_env("RELEASE_COOKIE")
    cookie_arg = "-setcookie #{release_cookie}"

    paths_arg = "-pa #{paths}"

    command_args = "-s Elixir.Sidekick start_sidekick #{parent_node} #{waiter_register}"

    args = "#{base_args} #{boot_file_args} #{cookie_arg} #{paths_arg} #{command_args}"

    "#{command} #{args}"
  end

  def start_sidekick([parent_node, waiter]) do
    Node.monitor(parent_node, true)

    #TODO Here we can start any kind of process, we just require a start and clean_up method
    Sidekick.Docker.start()
    send({waiter, parent_node}, {self(), :started})

    :erlang.system_info(:system_version)
    receive do
      {:nodedown, _node} ->
        Sidekick.Docker.clean_up()
        :init.stop()
    end
  end
end
