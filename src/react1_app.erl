-module(react1_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).


start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [ {"/", cowboy_static, {priv_file, react1, "static/index.html"}},
			   	{"/[...]", cowboy_static, {priv_dir, react1,  "static"}}]}
	]),
	cowboy:start_http(my_http_listener, 100, [{port, 8080}],
		[{env, [{dispatch, Dispatch}]}]
	),
	react1_sup:start_link().

stop(_State) ->
	ok.