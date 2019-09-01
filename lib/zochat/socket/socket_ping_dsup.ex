defmodule Zochat.PingDynamicSupervisor do
    @moduledoc """
        Supervise socket ping worker
    """

    use DynamicSupervisor
    require Logger

    def start_link(init_args) do
        Logger.debug("Starting PingDynamicSupervisor.")
        DynamicSupervisor.start_link(__MODULE__, init_args, name: __MODULE__)
    end

    def start_child(socket_pid) do
        # socket_pid: client_socket_pid.

        Logger.debug("Starting supervised keep-alive-ping-server for client #{inspect socket_pid}")
        spec = %{id: socket_pid, start: {Zochat.SocketPingWorker, :start_link, [socket_pid]}}
        DynamicSupervisor.start_child(__MODULE__, spec)
    end

    def terminate_child(socket_pid) do
        Logger.debug("Terminating ping-server for client #{inspect socket_pid}")
        DynamicSupervisor.terminate_child(__MODULE__, socket_pid)
    end

    @impl true
    def init(_init_args) do
        DynamicSupervisor.init(strategy: :one_for_one)
    end
end