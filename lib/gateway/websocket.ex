defmodule Gateway.Websocket do
  @moduledoc false
  require Logger

  use WebSockex

  def start_link({shard_id, shard_total}) do
    WebSockex.start_link(
      "wss://gateway.discord.gg/?v=6&encoding=etf", # todo: get gateway url from api endpoint
      __MODULE__,
      %{
        shard_id: shard_id,
        shard_total: shard_total,
        auth: false
      }
    )
  end

  def handle_frame({:binary, msg}, state) do
    decoded = :erlang.binary_to_term(msg)
    Logger.info("Received Message: #{inspect decoded}")

    case decoded.op do
      10 ->
        state = Map.put(state, :auth, true)
        Logger.info "OP 10 / Authorizing..."

        payload = make_payload 2, %{
          "token" => Application.get_env(:gateway, :token),
          "properties" => %{
            "$os" => "",
            "$browser" => "Kyoko",
            "$device" => "Kyoko",
            "$referrer" => "",
            "$referring_domain" => "",
          },
          "compress" => false,
          "shard" => [state[:shard_id], state[:shard_total]],
          "large_threshold" => 250,
        }

        {:reply, {:binary, payload}, state}
      unknown ->
        Logger.info "Received unknown opcode: #{unknown}"
        {:ok, state}
    end
  end

  def handle_disconnect(%{reason: reason}, state) do
    if state[:closed_by_client] do
      Logger.info "We closed the websocket with reason #{inspect(reason)}"
    else
      Logger.warn "Server closed the websocket with reason #{inspect(reason)}"
    end

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.info "Sending #{type} frame with payload: #{msg}"

    {:reply, frame, state}
  end

  defp make_payload(op, data) do
    payload = %{
      "op" => op,
      "d" => data
    }

    Logger.info("Payload: #{inspect payload}")

    payload
    |> :erlang.term_to_binary
  end
end
