defmodule ElixirObservability.Adapters.Repository.Account.AccountDataRepository do
  alias ElixirObservability.Adapters.Repository.Repo
  alias ElixirObservability.Adapters.Repository.Account.Data.AccountData
  alias ElixirObservability.Domain.Model.Account

  @behaviour ElixirObservability.Domain.Behaviours.AccountBehaviour

  def find_by_id(id), do: AccountData |> Repo.get(id) |> to_entity

  defp to_entity(nil), do: nil

  defp to_entity(data) do
    %Account{id: data.id, user_id: data.user_id, account: data.account, name: data.name, number: data.number,
     balance: data.balance, currency: data.currency, type: data.type, bank: data.bank,
     creation_date: data.creation_date, update_date: data.update_date}
  end
end
