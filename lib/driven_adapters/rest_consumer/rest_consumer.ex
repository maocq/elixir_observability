defmodule ElixirObservability.Adapters.RestConsumer.RestConsumer do

  @behaviour ElixirObservability.Domain.Behaviours.HelloBehaviour

  def hello(latency) do
    url = "http://localhost:3100/#{latency}"

    case Finch.build(:get, url) |> Finch.request(HttpFinch) do
      {:ok, %Finch.Response{body: body}} -> {:ok, body}
      error -> error
    end
  end
end
