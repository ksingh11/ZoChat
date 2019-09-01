defmodule Zochat.UserServer do
    @moduledoc """
        User Genserver, start with first websocket connection.
        Terminate if no websocket connection.

        Check if user already exists, return existing GenServer pid.
    """

    use GenServer
    require Logger

    def start_link(user_id) do
        user_pid = case GenServer.start_link(__MODULE__, user_id, name: :"#{user_id}") do
            {:ok, user_pid} -> user_pid
            {:error, {:already_started, user_pid}} -> user_pid
        end
        {:ok, user_pid}
    end

    @impl true
    def init(user_id) do
        user_channel = "notif:usr:#{user_id}"
        user_groups = Zochat.UserLib.get_user_subscribed_groups(user_id)
        
        # Subscribe pubsub channels
        Zochat.Pubsub.subscribe_user_channel(self(), [user_channel|user_groups])
        {:ok, %{user_id: user_id, clients: [], user_channel: user_channel, groups: user_groups}}
    end

    def add_client(user_id, client_pid) do
        # add new client to user
        Logger.debug("Add client_pid #{inspect client_pid} to user_pid: #{inspect user_id}")
        GenServer.cast(:"#{user_id}", {:add_client, client_pid})
    end

    def delete_client(user_id, client_pid) do
        # check if this was the only client, then close user process too.
        Logger.debug("Delete client_pid #{inspect client_pid} from user_id: #{inspect user_id}")
        GenServer.cast(:"#{user_id}", {:delete_client, client_pid})
    end

    def handle_message(user_id, client_pid, message) do
        # Handle forwarded messages from user's client sockets.
        GenServer.cast(:"#{user_id}", {message, client_pid})
    end

    def send_user_message(user_id, message, client_pid \\ nil) do
        GenServer.cast(:"#{user_id}", {:send_user_message, message, client_pid})
    end

    @impl true
    def handle_cast({:add_client, client_pid}, state) do
        # add new client pid to clients list.
        new_clients = [client_pid|state.clients]
        Logger.debug("Total active clients: #{length(new_clients)}")
        {:noreply, Map.put(state, :clients, new_clients)}
    end

    @impl true
    def handle_cast({:delete_client, client_pid}, state) do
        # remove client pid from clients list.
        new_clients = List.delete(state.clients, client_pid)
        Logger.debug("Total active clients: #{length(new_clients)}")

        # check if client list is empdy, stop user server
        if length(new_clients) === 0 do
            Logger.debug("initiate: close user server #{inspect self()}")
            Zochat.UserDynamicSupervisor.terminate_child(self())
        end
        {:noreply, Map.put(state, :clients, new_clients)}
    end

    @impl true
    def handle_cast({:send_user_message, message, _client_pid}, state) do
        # Send message to all the active clients.
        Logger.debug("Sending message to client #{inspect message}")
        state.clients
        |> Enum.each(&(Zochat.SocketHandler.send_client_message(&1, {:text,  "{},"<>message})))
        {:noreply, state}
    end

    # Handle client messages: Router
    @impl true
    def handle_cast({{:text, message}, client_pid}, state) do
        Zochat.UserMsgRouter.handle_user_message(message, client_pid, state)
        {:noreply, state}
    end

    @impl true
    def handle_cast({_frame, _client_pid}, state) do
        # handle :pong and other non matching messages.
        {:noreply, state}
    end

    @impl true
    def handle_info(pubsub_msg={:redix_pubsub, _, _, _, _}, state) do
        Logger.debug("#{inspect pubsub_msg}")
        Zochat.Pubsub.subscription_msg_handler(pubsub_msg, state)
        {:noreply, state}
    end
end
