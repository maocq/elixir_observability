defmodule ElixirObservability.Domain.UseCase.HelloUseCase do
  require Logger

  @account_behaviour Application.compile_env(:elixir_observability, :account_behaviour)
  @hello_behaviour Application.compile_env(:elixir_observability, :hello_behaviour)

  def hello() do
    Logger.info("Start use case")
    with {:ok, _} <- @hello_behaviour.hello(50),
         {:ok, _} <- @hello_behaviour.hello(20),
         account  <- @account_behaviour.find_by_id(4000),
         {:ok, _} <- @hello_behaviour.hello(80) do

      Logger.info("Updating account ...")
      updated_account = %{account | name: inspect(Timex.now)}
      {:ok, @account_behaviour.update(updated_account)}
    end
  end

end
