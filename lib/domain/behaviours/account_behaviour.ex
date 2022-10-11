defmodule ElixirObservability.Domain.Behaviours.AccountBehaviour do

  @callback find_by_id(number()) :: term
  @callback update(term) :: term
end
