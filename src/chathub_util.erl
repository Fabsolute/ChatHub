%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. May 2018 10:43
%%%-------------------------------------------------------------------
-module(chathub_util).
-author("ahmetturk").

%% API
-export([to_hex/1, is_string/1, is_char/1, get_method/1]).

to_hex(<<Hi:4, Lo:4, Rest/binary>>) ->
  [nibble_to_hex(Hi), nibble_to_hex(Lo) | to_hex(Rest)];
to_hex(<<>>) ->
  [];
to_hex(List) when is_list(List) ->
  to_hex(list_to_binary(List)).

is_string([H | T]) ->
  case is_char(H) of
    true
      -> is_string(T);
    false ->
      false
  end;
is_string([]) ->
  true;
is_string(_) ->
  false.

is_char(C) when is_integer(C), C >= 0, C < 16#D800 ->
  true;
is_char(C) when is_integer(C), C > 16#DFFF, C < 16#FFFE ->
  true;
is_char(C) when is_integer(C), C > 16#FFFF, C =< 16#10FFFF ->
  true;
is_char(_) ->
  false.

% PRIVATE
nibble_to_hex(0) -> $0;
nibble_to_hex(1) -> $1;
nibble_to_hex(2) -> $2;
nibble_to_hex(3) -> $3;
nibble_to_hex(4) -> $4;
nibble_to_hex(5) -> $5;
nibble_to_hex(6) -> $6;
nibble_to_hex(7) -> $7;
nibble_to_hex(8) -> $8;
nibble_to_hex(9) -> $9;
nibble_to_hex(10) -> $a;
nibble_to_hex(11) -> $b;
nibble_to_hex(12) -> $c;
nibble_to_hex(13) -> $d;
nibble_to_hex(14) -> $e;
nibble_to_hex(15) -> $f.

get_method(Properties) ->
  Method = proplists:get_value(<<"method">>, Properties),
  Data = proplists:get_value(<<"data">>, Properties),
  case Data of
    undefined ->
      {ok, undefined, undefined};
    _ ->
      {ok, get_method_from_string(Method), Data}
  end.

get_method_from_string(<<"auth">>) ->
  auth;
get_method_from_string(_) ->
  undefined.
