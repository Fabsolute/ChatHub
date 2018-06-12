%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Jun 2018 10:04
%%%-------------------------------------------------------------------
-module(chathub_handler).
-author("ahmetturk").

%% API
-export([undefined/1, auth/1, join/1]).

undefined(_) ->
  undefined.

auth(Data) ->
  Username = proplists:get_value(<<"username">>, Data),
  case Username of
    undefined ->
      undefined;
    Username ->
      case chathub_local_db:authenticate(self(), Username) of
        true ->
          [{<<"method">>, <<"auth">>}, {<<"status">>, <<"success">>}];
        {false, Reason} ->
          [{<<"method">>, <<"auth">>}, {<<"status">>, <<"failure">>}, {<<"reason">>, Reason}]
      end
  end.

join(Data) ->
  Channel = proplists:get_value(<<"channel">>, Data),
  case Channel of
    undefined ->
      undefined;
    Channel ->
      case chathub_local_db:join_channel(self(), Channel) of
        true ->
          []
      end
  end.

