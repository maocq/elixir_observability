defmodule OpentelemetryFinch do
  @moduledoc """
  """

  require OpenTelemetry.Tracer

  def setup(_opts \\ []) do
    attach_endpoint_start_handler()

    :ok
  end

  @doc false
  def attach_endpoint_start_handler() do
    :telemetry.attach(
      {__MODULE__, :request_stop},
      [:finch, :request, :stop],
      &__MODULE__.handle_request_stop/4,
      %{}
    )
  end

  def handle_request_stop(_event, measurements, meta, _config) do
    total_time = measurements.duration
    end_time = :opentelemetry.timestamp()
    start_time = end_time - total_time

    status =
      case meta.result do
        {:ok, response} -> response.status
        _ -> 0
      end

    attributes = %{
      "http.scheme": meta.request.scheme,
      "http.host": meta.request.host,
      "http.path": meta.request.path,
      "http.method": meta.request.method,
      "http.status": status,
    }

    s =
      OpenTelemetry.Tracer.start_span("client http", %{
        start_time: start_time,
        attributes: attributes,
        kind: :client
      })

    OpenTelemetry.Span.end_span(s)
  end
end
