defmodule Zochat.Webserver do
    def dispatch do
        routes = [
          {:_,
            [
              {"/ws/[...]", Zochat.SocketHandler, %{}},
              {"/", Zochat.Web.PageHandler, []},
              {:_, Zochat.Web.Http404, []}
            ]
          }
        ]
        :cowboy_router.compile(routes)
      end
end