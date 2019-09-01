defmodule Zochat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  import Supervisor.Spec, warn: false

  def start(_type, _args) do
    log()
    
    children = [
      %{
        id: :webserver,
        start:
          {:cowboy, :start_clear,
           [
             :webserver,
             %{max_connections: 999_999, socket_opts: [port: 4000]},
             %{max_keepalive: 1_000, env: %{dispatch: Zochat.Webserver.dispatch()}}
           ]},
        restart: :permanent,
        shutdown: :infinity,
        type: :supervisor
      },

      {Mongo, [name: :mongo, url: "mongodb://localhost:27017/zochat", pool_size: 2]},
      {Redix, {"redis://localhost:6379/0", [name: :zoredis]}},
      %{ 
        id: Redix.PubSub,
        start: {Redix.PubSub, :start_link, ["redis://localhost:6379/0", [name: :zopubsub]]}
      },
      
      supervisor(Zochat.PingDynamicSupervisor, [[]]),
      supervisor(Zochat.UserDynamicSupervisor, [[]]),
      worker(Zochat.PubsubListenServer, [[]]),
      supervisor(Task.Supervisor, [[name: Zochat.NotifTaskSup]]),
      # Starts a worker by calling: Zochat.Worker.start_link(arg)
      # {Zochat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    Logger.debug("Starting RootSupervisor.")
    opts = [strategy: :one_for_one, name: Zochat.RootSupervisor]
    Supervisor.start_link(children, opts)
  end

  defp log do
    Logger.debug "Starting Application..."
  end
end
