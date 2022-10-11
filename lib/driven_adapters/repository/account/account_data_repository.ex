defmodule ElixirObservability.Adapters.Repository.Account.AccountDataRepository do
  alias ElixirObservability.Adapters.Repository.Repo
  alias ElixirObservability.Adapters.Repository.Account.Data.AccountData
  alias ElixirObservability.Domain.Model.Account

  @behaviour ElixirObservability.Domain.Behaviours.AccountBehaviour

  def find_by_id(id), do: AccountData |> Repo.get(id) |> to_entity

  def update(entity) do
    row = %AccountData{id: entity.id}
    Repo.update!(Ecto.Changeset.change(row, %{user_id: entity.user_id, account: entity.account, name: entity.name, number: entity.number,
     balance: entity.balance, currency: entity.currency, type: entity.type, bank: entity.bank,
     creation_date: entity.creation_date, update_date: entity.update_date})) |> to_entity
  end

  defp to_entity(nil), do: nil

  defp to_entity(data) do
    %Account{id: data.id, user_id: data.user_id, account: data.account, name: data.name, number: data.number,
     balance: data.balance, currency: data.currency, type: data.type, bank: data.bank,
     creation_date: data.creation_date, update_date: data.update_date}
  end
end
