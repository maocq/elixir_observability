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


config :opentelemetry, :resource, service: %{name: "Elixir-MS"}

#config :opentelemetry, traces_exporter: :none

config :opentelemetry, :processors,
  otel_batch_processor: %{
#    exporter: {
#      :opentelemetry_zipkin,
#      %{address: 'http://localhost:9411/api/v2/spans', local_endpoint: %{service_name: "XXX"}}
#    }
    exporter: {
      :opentelemetry_exporter,
      %{endpoints: [{:http, 'localhost', 4318, []}]}
    }
  }

config :elixir_observability,
       account_behaviour: ElixirObservability.Adapters.Repository.Account.AccountDataRepository,
       hello_behaviour: ElixirObservability.Adapters.RestConsumer.RestConsumer

config :logger, :console,
       format: "$time [$level] $metadata$message \n",
       metadata: [:span_id, :trace_id]
