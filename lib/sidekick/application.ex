defmodule Sidekick.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    :net_kernel.start([:"mai2n@127.0.0.1"])
    {:ok, _node} = Sidekick.start()

    {:ok, self()}
  end
end
