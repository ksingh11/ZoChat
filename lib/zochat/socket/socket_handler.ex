defmodule Zochat.SocketHandler do
    @moduledoc """
        Handle socket connection from client applications.
        Extract user information from connection header.
        Map socket to user phandler process.

        Disconnects if no message for specified period.
    """
    require Logger
    @timeout Application.get_env(:zochat, :socket)[:timeout]
    @max_frame_size 8000000

    def init(req0, state) do
        Logger.debug("Initializing a new web-socket with idle_timeout: #{@timeout}")
        opts = %{idle_timeout: @timeout, max_frame_size: @max_frame_size}
        case :cowboy_req.parse_header("sec-websocket-protocol", req0) do
            :undefined ->
                {:cowboy_websocket, req0, state, opts}
            subprotocols ->
                case List.keymember?("mqtt", 1, subprotocols) do
                    true ->
                        req = :cowboy_req.set_resp_header("sec-websocket-protocol",
                                "mqtt", req0)
                        {:cowboy_websocket, req, state, opts}
                    false ->
                        req = :cowboy_req.reply(400, req0)
                        {:ok, req, state}
                end
        end
    end

    def websocket_init(_state) do
        # initiate ping worker, and store their pid in state.
        Logger.debug("websocket initialized!")
        state = case Application.get_env(:zochat, :socket)[:auto_ping_server] do
            true -> {:ok, ping_pid} = Zochat.PingDynamicSupervisor.start_child(self())
                    %{ping_pid: ping_pid}
            _ -> %{}
        end

        # Start or connect to user Server
        user_id = 123456_000
        {:ok, user_pid} = Zochat.UserDynamicSupervisor.get_user_server(user_id)
        
        # add client to user server
        Zochat.UserServer.add_client(user_id, self())
        {:reply, {:text, "Hello from the other side!"}, 
            Map.merge(state, %{user_id: user_id,  user_pid: user_pid, client_pid: self()})}
    end

    def websocket_handle(message, state) do
        # Forward message to user server
        Zochat.UserServer.handle_message(state.user_id, state.client_pid, message)
        {:ok, state}
    end

    # The following snippet forwards log messages 
    # to the client and ignores all others
    def websocket_info({:log, text}, state) do
        IO.puts "Text:" <> text
        {:reply, {:text, text}, state}
    end

    # Closing frames:
    def websocket_info(:close, state) do
        {:reply, {:close, 1000, "closing-reason"}, state}
    end

    def websocket_info(:ping, state) do
        # send ping opcode to client
        {:reply, :ping, state}
    end

    def websocket_info(message, state) do
        # Handle any message, reply to client
        {:reply, message, state}
    end

    def terminate(_reason, _req, state) do
        # terminate associated ping server if there is one.
        # notify user server that client is going down
        case Map.get(state, :ping_pid) do
            ping_worker_pid when is_pid(ping_worker_pid) ->
                Logger.debug("Terminate ping server")
                Zochat.PingDynamicSupervisor.terminate_child(ping_worker_pid)
            _ ->
                Logger.debug("No ping servers to stop!")
        end
        
        # notify user_server
        Zochat.UserServer.delete_client(Map.get(state, :user_id), self())
    end

    def send_client_message(client_pid, message) do
        # Send message to client
        send client_pid, message
    end
end
