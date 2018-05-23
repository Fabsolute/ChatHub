%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. May 2018 10:19
%%%-------------------------------------------------------------------
-module(chathub_ets).
-author("ahmetturk").

-behavior(gen_server).

-record(user, {
  username
}).

%% gen_server
-export([init/1, handle_call/3, handle_cast/2]).

%% API
-export([start/0, stop/0, connected/1, get_connections/0, disconnected/1, authenticate/2]).

start() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:cast(?MODULE, stop).

connected(Pid) ->
  gen_server:cast(?MODULE, {connected, Pid}).

disconnected(Pid) ->
  gen_server:cast(?MODULE, {disconnected, Pid}).

get_connections() ->
  gen_server:call(?MODULE, get_connections).

authenticate(Pid, Username) ->
  gen_server:call(?MODULE, {authenticate, Pid, Username}).

%% gen_server

init([]) ->
  chathub_uuid:start(),
  {ok, []}.

handle_call({authenticate, Pid, Username}, _From, Connections) ->
  Duplicated = [UserState#user.username || {_UserPid, UserState} <- Connections, UserState#user.username =/= Username],
  case length(Duplicated) of
    0 ->
      User = proplists:get_value(Pid, Connections),
      case User of
        nil ->
          NewUser = {Pid, #user{username = Username}},
          {reply, true, lists:keyreplace(Pid, 1, Connections, NewUser)};
        _ ->
          {reply, {false, already_authenticated}, Connections}
      end;
    _ ->
      {reply, {false, username_already_in_use}, Connections}
  end;
handle_call(get_connections, _From, Connections) ->
  {reply, Connections, Connections};
handle_call(Request, _From, Connections) ->
  io:format("wtf~p~n", [Request]),
  {noreply, Connections}.

handle_cast({connected, Pid}, Connections) ->
  {noreply, [{Pid, nil} | Connections]};
handle_cast({disconnected, Pid}, Connections) ->
  {noreply, proplists:delete(Pid, Connections)};
handle_cast(_Request, State) ->
  {noreply, State}.
