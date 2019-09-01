defmodule Zochat.Web.PageHandler do
    def init(req, state) do
        headers = %{"content-type" => "text/html"}
        body = "<h4>Welcome to the Machine!</h4>"
        resp = :cowboy_req.reply(200, headers, body, req)
        {:ok, resp, state}
    end

    def terminate(_reason, _req, _state) do
        :ok
    end
end

defmodule Zochat.Web.Http404 do
    @moduledoc """
        Handle unknown urls', return with response: 404 Not Found
    """
    def init(req, state) do
        resp = :cowboy_req.reply(404, req)
        {:ok, resp, state}
    end

    def terminate(_reason, _req, _state) do
        :ok
    end
end