import Config

config :zochat,
    site_url: "localhost:4000"

config :zochat, :repo,
    db_name: "Kaushal",
    db_host: "localhost"

config :zochat, :socket,
    timeout: 120_000,
    ping_interval: 60_000,
    auto_ping_server: false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

import_config "#{Mix.env()}.exs"