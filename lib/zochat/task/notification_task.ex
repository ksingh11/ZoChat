defmodule Zochat.NotifTask do
    require Logger

    def send_notification(message) do
        Task.Supervisor.start_child({Zochat.NotifTaskSup, Zochat.NodeManager.random_node}, 
                                    __MODULE__, :trigger_notification, [message])
    end

    def trigger_notification(message) do
        Logger.debug("Task: executing send notification task: #{inspect message}")
    end
end
