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
