-module(comment_handler).

-export([init/3]).
-export([terminate/3]).
-export([addcomment/2]).
-export([allowed_methods/2, 
	     content_types_provided/2, 
	     content_types_accepted/2,
	     to_json/2,
	     from_www_form/2]).

-record(comment, {author, text}).

init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
	{[<<"GET">>, <<"HEAD">>, <<"OPTIONS">>, <<"POST">>], Req, State}.

content_types_provided(Req, State) ->
	{[{{<<"application">>, <<"json">>, '*'}, to_json}], Req, State}.

content_types_accepted(Req, State) ->
	Content_types = [{{<<"application">>, <<"x-www-form-urlencoded">>, '*'}, from_www_form}],
	{Content_types, Req, State}.

to_json(Req, State) -> % json handler
    Comments = ets:lookup_element(store, comments, 2),
    Reply = n2o_json:encode(lists:map(fun comment2json/1,Comments)),
	{Reply, Req, State}.

from_www_form(Req, State) ->
	{ok, QS, Req2} = cowboy_req:body_qs(Req),
	[{<<"author">>,Author},{<<"text">>, Text}] = QS,
	addcomment(Author, Text),
	{true, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.

comment2json(#comment{author=Author, text=Text}) ->
	{struct,[{<<"author">>,Author},{<<"text">>,Text}]}.

addcomment(Author, Text) ->
	Comments = ets:lookup_element(store, comments, 2),
	NewComments = Comments ++ [#comment{author=Author, text=Text}],
	ets:insert(store,{comments, NewComments}).


