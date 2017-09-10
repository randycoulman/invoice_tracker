defmodule InvoiceTracker.Mixfile do
  @moduledoc false

  use Mix.Project

  def project do
    [app: :invoice_tracker,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: InvoiceTracker.CLI, name: "invoice"],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     dialyzer: [ignore_warnings: "config/dialyzer.ignore-warnings"]
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:briefly, "~> 0.3", only: :test},
      {:ex_cli, "~> 0.1.2"},
      {:credo, "~> 0.6", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:mock, "~> 0.3.1", only: :test},
      {:number, "~> 0.5.1"},
      {:poison, "~> 3.1"},
      {:short_maps, "~> 0.1.2"},
      {:table_rex, "~> 0.10"},
      {:tesla, "~> 0.7.1"},
      {:timex, "~> 3.1"},
      {:tzdata, "~> 0.1.8", override: true}
    ]
  end
end
