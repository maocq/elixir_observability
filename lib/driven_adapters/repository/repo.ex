defmodule ElixirObservability.Adapters.Repository.Repo do
  use Ecto.Repo,
  otp_app: :elixir_observability,
  adapter: Ecto.Adapters.Postgres
end
