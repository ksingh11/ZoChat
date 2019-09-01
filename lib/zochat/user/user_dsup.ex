defmodule Zochat.UserDynamicSupervisor do
    @moduledoc """
        Supervise user server.
    """
    use DynamicSupervisor
    require Logger

    def start_link(init_args) do
        Logger.debug("Starting UserDynamicSupervisor.")
        DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
    end

    @impl true
    def init(_init_args) do
        DynamicSupervisor.init(strategy: :one_for_one)
    end

    def get_user_server(user_id) do
        Logger.debug("Starting supervised user server for user_id: #{user_id}")
        spec = %{id: user_id, 
                start: {Zochat.UserServer, :start_link, [user_id]},
                restart: :transient}
        DynamicSupervisor.start_child(__MODULE__, spec)
    end

    def terminate_child(user_pid) do
        Logger.debug("Terminating user server for user_pid: #{inspect user_pid}.")
        DynamicSupervisor.terminate_child(__MODULE__, user_pid)
    end
    
end
