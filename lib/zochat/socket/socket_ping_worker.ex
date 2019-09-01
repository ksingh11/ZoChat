defmodule Zochat.SocketPingWorker do
    @moduledoc """
        Ping worker, keep triggering ping opcode via socket handler.
        Server sends ping opcode to check if client is alive, 
        In the interval of configured timeout.

        Starts independent GenServer for each client.
    """

    use GenServer
    import Logger
    @ping_interval Application.get_env(:zochat, :socket)[:ping_interval]

    def start_link(args) do
        # args: client_socket_pid.
        debug("Socket keep-alive ping interval: #{@ping_interval}")
        GenServer.start_link(__MODULE__, args)
    end

    def stop(pid) do
        GenServer.stop(pid)
    end

    @impl true
    def init(socket_pid) do
        # Monitor parent socket process
        Process.monitor(socket_pid)

        # schedule ping after certain interval
        schedule_ping()
        {:ok, socket_pid}
    end

    def schedule_ping() do
        # schedule to trigger ping after a interval
        Process.send_after(self(), :wsping, @ping_interval)
    end

    @impl true
    def handle_info(:wsping, socket_pid) do
        send socket_pid, :ping
        schedule_ping()
        {:noreply, socket_pid}
    end

    @impl true
    def handle_info({:DOWN, _ref, :process, _object, _reason}, socket_pid) do
        # Parent socket has been closed, close ping server too.
        {:stop, :normal, socket_pid}
    end

    @impl true
    def terminate(_reason, _state) do
        :ok
    end
end