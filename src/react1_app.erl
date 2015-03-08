-module(react1_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

-record(comment, {author, text}).

start(_Type, _Args) ->
	ets:new(store, [public, named_table]),
	Comments = [#comment{author = <<"Michael Arnoldus">>, text = <<"Dette er min kommentar - med fyld">>},
                #comment{author = <<"Jens Mortensen">>, text = <<"Men kunne ogsaa sige noget *helt andet* ">>}],
	ets:insert(store,{comments, Comments}),
	Dispatch = cowboy_router:compile([
		{'_', [ {"/", cowboy_static, {priv_file, react1, "static/index.html"}},
				{"/api/comments", comment_handler, []},
			   	{"/[...]", cowboy_static, {priv_dir, react1,  "static"}}]}
	]),
	cowboy:start_http(my_http_listener, 100, [{port, 8080}],
		[{env, [{dispatch, Dispatch}]}]
	),
	react1_sup:start_link().

stop(_State) ->
	ok.