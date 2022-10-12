defmodule OpentelemetryPlugCowboy do
  @moduledoc """
  """

  require OpenTelemetry.Tracer
  alias OpenTelemetry.Span

  @tracer_id __MODULE__

  def setup(_opts \\ []) do
    attach_endpoint_start_handler()
    attach_endpoint_stop_handler()
    attach_router_dispatch_exception_handler()

    :ok
  end


  @doc false
  def attach_endpoint_start_handler() do
    :telemetry.attach(
      {__MODULE__, :endpoint_start},
      [:plug, :router_dispatch, :start],
      &__MODULE__.handle_endpoint_start/4,
      %{}
    )
  end

  @doc false
  def attach_endpoint_stop_handler() do
    :telemetry.attach(
      {__MODULE__, :endpoint_stop},
      [:plug, :router_dispatch, :stop],
      &__MODULE__.handle_endpoint_stop/4,
      %{}
    )
  end


  @doc false
  def attach_router_dispatch_exception_handler do
    :telemetry.attach(
      {__MODULE__, :router_dispatch_exception},
      [:plug, :router_dispatch, :exception],
      &__MODULE__.handle_router_dispatch_exception/4,
      %{}
    )
  end

  @doc false
  def handle_endpoint_start(_event, _measurements, %{conn: %{adapter: adapter} = conn} = meta, _config) do
    :otel_propagator_text_map.extract(conn.req_headers)

    peer_data = Plug.Conn.get_peer_data(conn)

    user_agent = header_value(conn, "user-agent")
    peer_ip = Map.get(peer_data, :address)

    attributes = %{
      "http.client_ip": client_ip(conn),
      "http.flavor": http_flavor(adapter),
      "http.host": conn.host,
      "http.method": conn.method,
      "http.scheme": "#{conn.scheme}",
      "http.target": conn.request_path,
      "http.user_agent": user_agent,
      "net.host.ip": to_string(:inet_parse.ntoa(conn.remote_ip)),
      "net.host.port": conn.port,
      "net.peer.ip": to_string(:inet_parse.ntoa(peer_ip)),
      "net.peer.port": peer_data.port,
      "net.transport": :"IP.TCP"
    }

    OpentelemetryTelemetry.start_telemetry_span(@tracer_id, "HTTP #{conn.method}", meta, %{
      kind: :server,
      attributes: attributes
    })
  end

  @doc false
  def handle_endpoint_stop(_event, _measurements, %{conn: conn} = meta, _config) do
    ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

    Span.set_attribute(ctx, :"http.status_code", conn.status)

    if conn.status >= 500 do
      Span.set_status(ctx, OpenTelemetry.status(:error, ""))
    end

    OpentelemetryTelemetry.end_telemetry_span(@tracer_id, meta)
  end

  @doc false
  def handle_router_dispatch_exception(
        _event,
        _measurements,
        %{kind: kind, reason: reason, stacktrace: stacktrace} = meta,
        _config
      ) do
    if OpenTelemetry.Span.is_recording(OpenTelemetry.Tracer.current_span_ctx()) do
      ctx = OpentelemetryTelemetry.set_current_telemetry_span(@tracer_id, meta)

      {[reason: reason], attrs} =
        normalize(reason)
        |> Keyword.split([:reason])

      exception = Exception.normalize(kind, reason, stacktrace)

      Span.record_exception(ctx, exception, stacktrace, attrs)
      Span.set_status(ctx, OpenTelemetry.status(:error, ""))
    end
  end

  defp http_flavor({_adapter_name, meta}) do
    case Map.get(meta, :version) do
      :"HTTP/1.0" -> :"1.0"
      :"HTTP/1.1" -> :"1.1"
      :"HTTP/2.0" -> :"2.0"
      :"HTTP/2" -> :"2.0"
      :SPDY -> :SPDY
      :QUIC -> :QUIC
      nil -> ""
    end
  end

  defp client_ip(%{remote_ip: remote_ip} = conn) do
    case header_value(conn, "x-forwarded-for") do
      "" ->
        remote_ip
        |> :inet_parse.ntoa()
        |> to_string()

      ip_address ->
        ip_address
        |> String.split(",", parts: 2)
        |> List.first()
    end
  end

  defp header_value(conn, header) do
    case Plug.Conn.get_req_header(conn, header) do
      [] ->
        ""

      [value | _] ->
        value
    end
  end

  defp normalize(%{reason: reason}), do: normalize(reason)
  defp normalize(:badarg), do: [reason: :badarg]
  defp normalize(:badarith), do: [reason: :badarith]
  defp normalize(:system_limit), do: [reason: :system_limit]
  defp normalize(:cond_clause), do: [reason: :cond_clause]
  defp normalize(:undef), do: [reason: :undef]
  defp normalize({:badarity, {fun, args}}) do
    {:arity, arity} = Function.info(fun, :arity)
    [reason: :badarity, function: _inspect(fun), arity: arity, args: _inspect(args)]
  end
  defp normalize({:badfun, term}), do: [reason: :badfun, term: _inspect(term)]
  defp normalize({:badstruct, struct, term}), do: [reason: :badstruct, struct: struct, term: _inspect(term)]
  defp normalize({:badmatch, term}), do: [reason: :badmatch, term: _inspect(term)]
  defp normalize({:badmap, term}), do: [reason: :badmap, term: _inspect(term)]
  defp normalize({:badbool, op, term}), do: [reason: :badbool, operator: op, term: _inspect(term)]
  defp normalize({:badkey, key}), do: [reason: :badkey, key: key]
  defp normalize({:badkey, key, map}), do: [reason: :badkey, key: key, map: _inspect(map)]
  defp normalize({:case_clause, term}), do: [reason: :case_clause, term: _inspect(term)]
  defp normalize({:with_clause, term}), do: [reason: :with_clause, term: _inspect(term)]
  defp normalize({:try_clause, term}), do: [reason: :try_clause, term: _inspect(term)]
  defp normalize({:badarg, payload}), do: [reason: :badarg, payload: _inspect(payload)]
  defp normalize(other), do: [reason: other]
  defp normalize(other, _stacktrace), do: [reason: other]

  defp _inspect(term) do
    if String.Chars.impl_for(term) do
      term
    else
      inspect(term)
    end
  end
end
