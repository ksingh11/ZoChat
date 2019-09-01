defmodule Zochat.PubsubListenServer do
    @moduledoc """
        Listen to all pubsub channels, route messages accordingly.
        # TODO: remove deleted user, groups from pubsub.
        # TODO: check unsubscribed channels by user.
    """
    use GenServer
    require Logger

    def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: :pubsub_listener)
    end

    @impl true
    def init(_args) do
        patterns = ["notif:usr:*", "notif:grp:*"]
        Redix.PubSub.psubscribe(:zopubsub, patterns, self())
        {:ok, %{}}
    end

    @impl true
    def handle_info(pubsub_msg={:redix_pubsub, _pid, _ref, message_type, message}, state) do
        # {:redix_pubsub, pubsub_pid, subscription_ref, message_type, message_properties}
        Logger.debug("Listener: #{inspect pubsub_msg}")
        message_notification(message_type, message)
        {:noreply, state}
    end

    defp message_notification(:pmessage, message) do
        Zochat.NotifTask.send_notification(message.payload)
    end

    defp message_notification(message_type, message) do
        Logger.debug("Uncaptured pubsub message_type: #{inspect message_type}, message: #{inspect message}")
    end
end
