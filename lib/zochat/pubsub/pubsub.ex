defmodule Zochat.Pubsub do
    require Logger

    def publish_user_channel(user_channel, message) do
        Logger.debug("Publish to: #{user_channel}, message: #{message}")
        Redix.command!(:zoredis, ["PUBLISH", "#{user_channel}", "#{message}"])
    end

    def subscribe_user_channel(user_pid, channels \\ []) do
        Logger.debug("subscribe user pid to channels: #{inspect channels}")
        channels
        |> Enum.each(&(Redix.PubSub.subscribe(:zopubsub, &1, user_pid)))
    end
    
    def subscription_msg_handler(
        {:redix_pubsub, _pubsub_pid, _subs_ref, _message_type, message}=_pubsub_msg, 
        user_state) do
        Logger.debug("#{inspect message}, user_state: #{inspect user_state}")
        Zochat.UserServer.send_user_message(user_state.user_id, Map.get(message, :payload, "subsribed"))
    end
end
