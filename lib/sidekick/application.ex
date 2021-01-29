defmodule Sidekick.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do

    #Doesn't work in release mode
    #:net_kernel.start([:"main@127.0.0.1"])

    {:ok, _node} = Sidekick.start()

    {:ok, self()}
  end
end
