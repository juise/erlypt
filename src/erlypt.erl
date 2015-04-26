-module(erlypt).

%% API
-export([main/1]).

-define(CURRY(X, B), fun(X) -> B end).

%%%===================================================================
%%% API
%%%===================================================================

main([Template]) ->
    Tmpl = list_to_binary(Template),
    [] = parse(Tmpl),
    {ok, Pattern} = re:compile(transform(Tmpl)),
    Fun = fun(Message) -> match(Pattern, Message) end,
    loop(Fun);

main(["-d", Template]) ->
    Tmpl = list_to_binary(Template),
    Terms = parse(Tmpl),
    {ok, Pattern} = re:compile(transform(Tmpl)),
    Fun = fun(Message) -> match(Pattern, Terms, Message) end,
    loop(Fun);

main(_) ->
    io:format("Usage:~n erlypt [-d] \"pattern\"~n").

%%%===================================================================
%%% Internal functions
%%%===================================================================

loop(Fun) ->
    case io:get_line('') of
        eof ->
            ok;
        Message ->
            Fun(Message) andalso io:format("~s", [Message]),
            loop(Fun)
    end.

transform(Template) ->
    lists:foldl(fun(F, Acc) -> F(Acc) end, Template,
                [?CURRY(Tmpl_, re:replace(Tmpl_, <<"(?<!%){(\\d+)}">>,                      <<"\\\\{\\1\\\\}">>, [global, {return, binary}])),
                 ?CURRY(Tmpl_, re:replace(Tmpl_, <<"[\\)\\(\\]\\[\\^\\$\\.\\+\\*\\?\\|]">>, <<"\\\\&">>,         [global, {return, binary}])),

                 ?CURRY(Tmpl_, re:replace(Tmpl_, <<"%{\\d+}">>,        <<"(\\\\w+(\\\\w| )*?)">>,          [global, {return, binary}])), %% named captured subpatterns,
                 ?CURRY(Tmpl_, re:replace(Tmpl_, <<"%{\\d+G}">>,       <<"(\\\\w+(\\\\w| )*)">>,           [global, {return, binary}])), %% used for debug purposes
                 ?CURRY(Tmpl_, re:replace(Tmpl_, <<"%{\\d+S(\\d+)}">>, <<"(\\\\w+(\\\\w* ){\\1}\\\\w+)">>, [global, {return, binary}])), %% i.e. (regexp)
                 ?CURRY(Tmpl_, <<"^", Tmpl_/bitstring, "$">>)]).

%% for debug purposes
parse(Template) ->
    case re:run(Template, <<"%{(\\d+)(S\\d+|G)*}">>, [global, {capture, all, binary}]) of
        {match, Terms} ->
            {T1, T2} = lists:foldl(fun([X, Y | _], {Xs, Ys}) -> {[X | Xs], [Y | Ys]} end, {[], []}, Terms),
            case lists:sort(T2 -- lists:usort(T2)) of
                [] ->
                    lists:reverse(T1);
                 T3 ->
                    io:format("Duplicated tokens: ~s~n", [lists:foldl(fun(Term, Acc) -> [Term, <<", ">> | Acc] end, [hd(T3)], tl(T3))]),
                    halt(1)
            end;
        nomatch ->
            []
    end.

match(Pattern, Message) ->
    case re:run(Message, Pattern, [global, {capture, none}]) of
        match ->
            true;
        nomatch ->
            false
    end.

%% for debug purposes
match(Pattern, Terms, Message) ->
    IDs = lists:seq(1, length(Terms) * 2, 2),
    case re:run(Message, Pattern, [{capture, IDs, binary}]) of
        {match, SubStrs} ->
            [io:format("~8s = '~s'~n", [Term, SubStr]) || {Term, SubStr} <- lists:zip(Terms, SubStrs)],
            true;
        match ->
            true;
        nomatch ->
            false
    end.

