defmodule Sidekick.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    {:ok, _node} = :slave.start('127.0.0.1', :test)
    {:ok, _node} = Sidekick.start()

    {:ok, self()}
  end
end
