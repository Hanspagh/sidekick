defmodule Sidekick.MixProject do
  use Mix.Project

  def project do
    [
      app: :sidekick,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp aliases do
    [
      compile: [&gen_boot/1, "compile"],
    ]
  end

  defp consultable(term) do
    IO.chardata_to_string(:io_lib.format("%% coding: utf-8~n~tp.~n", [term]))
  end

  defp get_version(app) do
    path = :code.lib_dir(app)
    {:ok, [{:application, ^app, properties}]} = :file.consult(Path.join(path, "ebin/#{app}.app"))
    Keyword.fetch!(properties, :vsn)
  end

  defp gen_boot(_) do
    Mix.shell().info("Generating node.rel file")

    # apps = :application.which_applications()
    # |> Enum.filter(&(Kernel.match?({:kernel, _, _}, &1) or Kernel.match?({:stdlib, _, _}, &1)))
    # |> Enum.map(fn {app, _extra, version} -> {app, version} end)

    apps = [:kernel, :stdlib, :elixir, :compiler]
    |> Enum.map(&({&1, get_version(&1)}))

    rel_spec = {:release, {'node', '0.1.0'}, {:erts, :erlang.system_info(:version)}, apps}
    File.write!("priv/node.rel", consultable(rel_spec))

    Mix.shell().info("Generating node.boot file")
    :systools.make_script('priv/node', [:silent])
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sidekick.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
