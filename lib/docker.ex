defmodule Sidekick.Docker do
  def start() do
    IO.inspect("Starting Docker")
    init()
  end

  def init() do
    System.cmd("docker", ["run", "-dt", "--name", "busybox", "busybox"])
    :ok
  end

  def clean_up() do
    System.cmd("docker", ["rm", "-f", "busybox"])
  end

  def mem() do
    :erlang.memory()
  end
end
