%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. May 2018 11:15
%%%-------------------------------------------------------------------
-module(chathub_connection).
-author("ahmetturk").

%% API
-export([json_handle/3, no_response/2, to_json/1, response/3]).

json_handle(Properties, Request, State) ->
  {ok, Method, Data} = chathub_util:get_method(Properties),
  Response = chathub_handler:Method(Data),
  case Response of
    undefined ->
      no_response(Request, State);
    Message ->
      response(Message, Request, State)
  end.

% PRIVATE

no_response(Request, State) ->
  {ok, Request, State}.

response({text, _} = Message, Request, State) ->
  {reply, Message, Request, State};
response({json, Message}, Request, State) ->
  response(to_json(Message), Request, State);
response(Message, Request, State) when is_binary(Message) ->
  response({text, Message}, Request, State);
response(Message, Request, State) ->
  response({json, Message}, Request, State).

to_json(Properties) ->
  {ok, Content} = jsone_encode:encode(Properties),
  Content.
