erlypt
======

Erlang pattern translator

#### Building

$ make

#### Testing

$ make test

#### Running

$ cat priv/fish | ./erlypt "a %{0}"

$ cat priv/fish | ./erlypt "metus %{0} %{1S0}"

$ cat priv/fish | ./erlypt -d "sit %{0} %{1S1} %{2G}"

