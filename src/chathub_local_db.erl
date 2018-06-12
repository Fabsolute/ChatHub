%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. May 2018 10:19
%%%-------------------------------------------------------------------
-module(chathub_local_db).
-author("ahmetturk").

-behavior(gen_server).

-record(user, {
  username,
  channel
}).

%% gen_server
-export([start/0, stop/0, init/1, handle_call/3, handle_cast/2]).

%% API
-export([connected/1, get_connections/0, disconnected/1, authenticate/2, join_channel/2]).

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


join_channel(Pid, Channel) ->
  gen_server:call(?MODULE, {join_channel, Pid, Channel}).

%% gen_server

init([]) ->
  chathub_uuid:start(),
  {ok, []}.

handle_call({authenticate, Pid, Username}, _From, Connections) ->
  User = proplists:get_value(Pid, Connections),
  case User of
    undefined ->
      case has_duplicate(Username, Connections) of
        false ->
          NewUser = {Pid, #user{username = Username}},
          reply(true, lists:keyreplace(Pid, 1, Connections, NewUser));
        true ->
          reply({false, username_already_in_use}, Connections)
      end;
    _ ->
      reply({false, already_authenticated}, Connections)
  end;
handle_call({join_channel, Pid, Channel}, _From, Connections) ->
  case proplists:get_value(Pid, Connections) of
    undefined ->
      undefined;
    User ->
      case User#user.channel of
        undefined ->
          NewUser = {Pid, User#user{channel = Channel}},
          reply(true, lists:keyreplace(Pid, 1, Connections, NewUser));
        _ ->
          reply({false, user_already_on_a_channel}, Connections)
      end
  end;
handle_call(get_connections, _From, Connections) ->
  reply(Connections, Connections);
handle_call(_Request, _From, Connections) ->
  noreply(Connections).

handle_cast({connected, Pid}, Connections) ->
  noreply([{Pid, undefined} | Connections]);
handle_cast({disconnected, Pid}, Connections) ->
  noreply(proplists:delete(Pid, Connections));
handle_cast(_Request, State) ->
  noreply(State).

% PRIVATE

reply(Reply, State) ->
  {reply, Reply, State}.

noreply(State) ->
  {noreply, State}.

has_duplicate(Username, Connections) ->
  Duplicated = [
    UserState#user.username || {_UserPid, UserState} <- Connections,
    UserState =/= undefined,
    UserState#user.username == Username
  ],
  case length(Duplicated) of
    0 -> false;
    _ -> true
  end.
