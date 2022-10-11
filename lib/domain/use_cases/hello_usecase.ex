defmodule ElixirObservability.Domain.UseCase.HelloUseCase do

  @account_behaviour Application.compile_env(:elixir_observability, :account_behaviour)
  @hello_behaviour Application.compile_env(:elixir_observability, :hello_behaviour)

  def hello() do
    with {:ok, _} <- @hello_behaviour.hello(0),
         {:ok, _} <- @hello_behaviour.hello(0),
         account  <- @account_behaviour.find_by_id(4000),
         {:ok, _} <- @hello_behaviour.hello(0) do

      updated_account = %{account | name: inspect(Timex.now)}
      {:ok, @account_behaviour.update(updated_account)}
    end
  end

end
