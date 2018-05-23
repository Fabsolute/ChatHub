%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. May 2018 10:29
%%%-------------------------------------------------------------------
-module(chathub_uuid).
-author("ahmetturk").

-behavior(gen_server).
%% gen_server
-export([init/1, handle_call/3, handle_cast/2]).
%% API
-export([start/0, stop/0, new/0, random/0]).

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:cast(?MODULE, stop).

new() ->
  gen_server:call(?MODULE, new).

random() ->
  list_to_binary(random(16)).

random(Count) ->
  chathub_util:to_hex(crypto:strong_rand_bytes(Count)).

%% gen_server

init([]) ->
  {ok, {sequential, new_prefix(), inc()}}.

handle_call(new, _From, {sequential, Prefix, Sequence}) ->
  Result = list_to_binary(Prefix ++ io_lib:format("~6.16.0b", [Sequence])),
  case Sequence >= 16#fff000 of
    true ->
      {reply, Result, {sequential, new_prefix(), inc()}};
    _ -> {reply, Result, {sequential, Prefix, Sequence + inc()}}
  end;
handle_call(_Request, _From, State) ->
  {noreply, State}.

handle_cast(stop, State) ->
  {stop, normal, State};
handle_cast(_Request, State) ->
  {noreply, State}.

% PRIVATE

inc() ->
  rand:uniform(16#ffe).

new_prefix() ->
  random(13).