# distributed-erlang

NB: The original code described in the blog post has been reviewed by someone who knows a lot more about Erlang than me! Thanks Pierre Fenoll. The bits that differ from listings in the blog are now more idiomatic.

PoC for distributed Erlang

The challenge is to have one container receive HTTP requests
and delegate the processing of the request to one of a set of
other containers, depending on some property of the URL.

http://blog.scottlogic.com/2016/01/25/playing-with-docker-compose-and-erlang.html
