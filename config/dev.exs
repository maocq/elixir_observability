import Config

config :elixir_observability, timezone: "America/Bogota"

config :elixir_observability,
       http_port: 8083,
       enable_server: true,
       secret_name: "",
       region: "",
       version: "0.0.1",
       in_test: false,
       custom_metrics_prefix_name: "elixir_observability_local"

config :logger,
       level: :debug

config :elixir_observability, ElixirObservability.Adapters.Repository.Repo,
       database: "compose-postgres",
       username: "compose-postgres",
       password: "compose-postgres",
       hostname: "localhost",
       pool_size: 10,
       queue_target: 5000,
       timeout: :timer.minutes(1)


config :elixir_observability,
       account_behaviour: ElixirObservability.Adapters.Repository.Account.AccountDataRepository,
       hello_behaviour: ElixirObservability.Adapters.RestConsumer.RestConsumer
