.PHONY: all test clean

REBAR=$(shell which rebar || echo ./rebar)

all: 	$(REBAR)
		$(REBAR) compile
		$(REBAR) escriptize

test:
		$(REBAR) eunit skip_deps=true

clean:
		$(REBAR) clean
		rm -rf ./rebar
		rm -rf ./ebin
		rm -rf ./erl_crash.dump

# Get rebar if it doesn't exist

REBAR_URL=https://cloud.github.com/downloads/basho/rebar/rebar

./rebar:
	erl -noinput -noshell -s inets -s ssl \
		-eval '{ok, _} = httpc:request(get, {"${REBAR_URL}", []}, [], [{stream, "${REBAR}"}])' \
		-s init stop
	chmod +x ${REBAR}
