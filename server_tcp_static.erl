-module(server_tcp_static).
-export([start/1]).

start(Response) ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket, Response).

loop(Socket, Response) ->
    receive
        {tcp, Socket, _Bin} ->
            gen_tcp:send(Socket, Response),
            loop(Socket, Response);
        {tcp_closed, Socket} ->
            io:format("Server socket closed~n")
    end.
