defmodule Zochat.UserMsgRouter do
    def handle_user_message(message, _client_pid, state) do
        Zochat.UserDB.save_user_msg(state.user_id, message)
        Zochat.Pubsub.publish_user_channel(state.user_channel, message)

        # Explicitely send message to user websocket
        # Zochat.UserServer.send_user_message(state.user_id, message)
    end
end