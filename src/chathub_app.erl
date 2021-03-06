-module(chathub_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {
      '_', [
      {"/", cowboy_static, {priv_file, chathub, "index.html"}},
      {"/websocket", chathub_ws_handler, []},
      {"/static/[...]", cowboy_static, {priv_dir, chathub, "static"}}
    ]}
  ]),
  {ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [{env, [{dispatch, Dispatch}]}]),
  chathub_local_db:start(),
  chathub_sup:start_link().

stop(_State) ->
  ok.
