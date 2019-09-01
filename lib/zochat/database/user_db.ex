defmodule Zochat.UserDB do\
    require Logger

    def save_user_msg(user_id, message) do
        # Save user message to db
        Logger.debug("Saving to user (id: #{user_id}) DB, message: #{message}")
        insert_user_msg(user_id, message)
    end

    def save_group_msg(_user_id, _message) do
        
    end

    defp insert_user_msg(user_id, message) do
        Mongo.insert_one(:mongo, "messages", %{from: user_id, message: message, created_at: Zochat.Time.timestamp})
    end

    defp insert_group_msg do
        Logger.debug("Inserting Group message")
    end
end