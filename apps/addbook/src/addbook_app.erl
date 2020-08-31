%%%-------------------------------------------------------------------
%% @doc addbook public API
%% @end
%%%-------------------------------------------------------------------

-module(addbook_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
  addbook_sup:start_link().

stop(_State) ->
  ok.

%% internal functions
