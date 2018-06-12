%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. May 2018 11:27
%%%-------------------------------------------------------------------
-module(chathub_ws_handler).
-author("ahmetturk").
%% API
-export([init/3, websocket_init/3, websocket_handle/3, websocket_info/3, websocket_terminate/3]).

init({tcp, http}, _Request, _Options) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Request, _Options) ->
  chathub_local_db:connected(self()),
  {ok, Request, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  case jsone:try_decode(Msg, [{object_format, proplist}]) of
    {ok, Properties, _} ->
      chathub_connection:json_handle(Properties, Req, State);
    _ ->
      chathub_connection:no_response(Req, State)
  end;
websocket_handle(_Data, Request, State) ->
  {ok, Request, State}.

websocket_info(_Info, Request, State) ->
  {ok, Request, State}.

websocket_terminate(_Reason, _Req, _State) ->
  chathub_local_db:disconnected(self()),
  ok.
