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

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  chathub_ets:connected(self()),
  io:fwrite("websocket initialized ~p ~n", [self()]),
  {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
  case jsone:try_decode(Msg, [{object_format, proplist}]) of
    {ok, Properties, _} ->
      json_handle(Properties, Req, State);
    _ ->
      no_response(Req, State)
  end;
websocket_handle(_Data, Req, State) ->
  {ok, Req, State}.

websocket_info(_Info, Req, State) ->
%%  io:fwrite("websocket list ~p ~n", [chathub_ets:get_connections()]),
  {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
  io:fwrite("websocket terminated ~p ~n", [self()]),
  chathub_ets:disconnected(self()),
  ok.


json_handle(Properties, Req, State) ->
  Method = proplists:get_value(<<"method">>, Properties),
  case Method of
    <<"auth">> ->
      handle_auth(Properties, Req, State);
    <<"message">> ->
      handle_message(Properties, Req, State);
    _ ->
      no_response(Req, State)
  end.

handle_auth(Properties, Request, State) ->
  Username = proplists:get_value(<<"username">>, Properties),
  case Username of
    undefined ->
      no_response(Request, State);
    Username ->
      case chathub_ets:authenticate(self(), Username) of
        true ->
          send_json([{<<"command">>, <<"auth">>}, {<<"status">>, <<"success">>}], Request, State);
        {false, Reason} ->
          send_json([{<<"command">>, <<"auth">>}, {<<"status">>, <<"failure">>}, {<<"reason">>, Reason}], Request, State)
      end
  end.

handle_message(_Properties, _Request, _State) ->
  erlang:error(not_implemented).

no_response(Request, State) ->
  {ok, Request, State}.


send_json(Properties, Request, State) ->
  {ok, Content} = jsone_encode:encode(Properties),
  {reply, {text, Content}, Request, State}.