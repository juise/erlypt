-module(erlypt_tests).

-include_lib("eunit/include/eunit.hrl").

transform_test() ->
    %% {N}
    ?assertEqual(<<"^foo (\\w+(\\w| )*?) is a bar$">>, erlypt:transform(<<"foo %{0} is a bar">>)),
    ?assertEqual(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?)$">>, erlypt:transform(<<"foo %{0} is a %{1}">>)),
    ?assertEqual(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?) big (\\w+(\\w| )*?)$">>, erlypt:transform(<<"foo %{0} is a %{1} big %{2}">>)),

    %% {NS#}
    ?assertEqual(<<"^foo (\\w+(\\w* ){1}\\w+) a bar$">>, erlypt:transform(<<"foo %{0S1} a bar">>)),
    ?assertEqual(<<"^foo (\\w+(\\w* ){3}\\w+) big (\\w+(\\w* ){0}\\w+)$">>, erlypt:transform(<<"foo %{0S3} big %{1S0}">>)),

    %% {NG}
    ?assertEqual(<<"^foo (\\w+(\\w| )*) is a bar$">>, erlypt:transform(<<"foo %{0G} is a bar">>)),
    ?assertEqual(<<"^foo (\\w+(\\w| )*) is a (\\w+(\\w| )*)$">>, erlypt:transform(<<"foo %{0G} is a %{1G}">>)),

    ?assertEqual(<<"^foo (\\w+(\\w| )*?) (\\w+(\\w* ){1}\\w+) (\\w+(\\w| )*)$">>, erlypt:transform(<<"foo %{0} %{1S1} %{2G}">>)),
    ok.

parse_test() ->
    %% {N}
    ?assertEqual([<<"%{0}">>], erlypt:parse(<<"foo %{0} is a bar">>)),
    ?assertEqual([<<"%{0}">>, <<"%{1}">>], erlypt:parse(<<"foo %{0} is a %{1}">>)),

    %% {NS#}
    ?assertEqual([<<"%{0S1}">>], erlypt:parse(<<"foo %{0S1} a bar">>)),
    ?assertEqual([<<"%{0S1}">>, <<"%{1S0}">>], erlypt:parse(<<"foo %{0S1} a %{1S0}">>)),

    %% {NG}
    ?assertEqual([<<"%{0G}">>], erlypt:parse(<<"foo %{0G} is a bar">>)),
    ?assertEqual([<<"%{0G}">>, <<"%{1G}">>], erlypt:parse(<<"foo %{0G} is %{1G} bar">>)),

    ?assertEqual([<<"%{0}">>, <<"%{1S1}">>,<<"%{2G}">>], erlypt:parse(<<"foo %{0} %{1S} %{1S1} %{2S} %{2G} %{3S}">>)),
    ok.

match_test() ->
    %% {N}
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a bar$">>, <<"foo blah is a bar">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) a (\\w+(\\w| )*?)$">>, <<"foo blah is a very  big   boat">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?) big (\\w+(\\w| )*?)$">>, <<"foo blah is a very big boat ">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?) big (\\w+(\\w| )*?) boat$">>, <<"foo blah is a very big yellow boat">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?) big (\\w+(\\w| )*?)$">>, <<"foo blah is a very big yellow boat or sub">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| )*?) big (\\w+(\\w| )*?)$">>, <<"foo blah is a very big yellow boat    sub  ">>)),

    %% {NS#}
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w* ){1}\\w+) a bar$">>, <<"foo blah is a bar">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w* ){3}\\w+) big (\\w+(\\w* ){0}\\w+)$">>, <<"foo blah is a very big boat">>)),
    ?assertEqual(true, erlypt:match(<<"^(\\w+(\\w* ){1}\\w+) is a (\\w+(\\w* ){2}\\w+)$">>, <<"foo blah is a very big boat">>)),
    ?assertEqual(true, erlypt:match(<<"^(\\w+(\\w* ){1}\\w+) is (\\w+(\\w* ){2}\\w+) yellow (\\w+(\\w* ){1}\\w+) sub$">>, <<"foo blah is a very big yellow boat or sub">>)),
    ?assertEqual(true, erlypt:match(<<"^(\\w+(\\w* ){1}\\w+) is (\\w+(\\w* ){2}\\w+) yellow (\\w+(\\w* ){1}\\w+) sub$">>, <<"foo blah is a  big yellow boat or sub">>)),

    %% {NG}
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*) is a bar$">>, <<"foo bar is a foo bar is a bar">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*) is a (\\w+(\\w| )*)$">>, <<"foo bar is a foo bar is a big boat">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*) is a (\\w+(\\w| )*) sub$">>, <<"foo bar is a foo bar is a big yellow boat or sub">>)),
    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*) is a (\\w+(\\w| )*)$">>, <<"foo bar is a foo bar is a big yellow boat or   sub or so">>)),

    ?assertEqual(true, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| ){0})$">>, <<"foo blah is a bar">>)),
    ?assertEqual(false, erlypt:match(<<"^foo (\\w+(\\w| )*?) is a (\\w+(\\w| ){0})$">>, <<"foo blah is a very big boat">>)),

    ?assertEqual(true, erlypt:match(<<"^the (\\w+(\\w* ){1}\\w+) (\\w+(\\w| )*?) ran away$">>, <<"the big brown fox ran away">>)),
    ?assertEqual(false, erlypt:match(<<"^the (\\w+(\\w* ){1}\\w+) (\\w+(\\w| )*?) ran away$">>, <<"the big fox ran away">>)),
    ok.

