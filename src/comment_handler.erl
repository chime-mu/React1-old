-module(comment_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).
-export([addcomment/2]).

-record(state, {}).
-record(comment, {author, text}).

init(_, Req, _Opts) ->
	{ok, Req, #state{}}.

handle(Req, State=#state{}) ->
    Comments = ets:lookup_element(store, comments, 2),
	{ok, Req2} = cowboy_req:reply(200, 
		[{<<"content-type">>, <<"application/json">>}],
		n2o_json:encode(lists:map(fun comment2json/1,Comments)),
		Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

comment2json(#comment{author=Author, text=Text}) ->
	{struct,[{<<"author">>,Author},{<<"text">>,Text}]}.

addcomment(Author, Text) ->
	Comments = ets:lookup_element(store, comments, 2),
	NewComments = [#comment{author=Author, text=Text} | Comments],
	ets:insert(store,{comments, NewComments}).


