import Config

config :zochat, :repo,
    db_name: "Kaushal",
    db_host: "localhost"


config :zochat, :socket,
    timeout: 120_000,
    ping_interval: 60_000