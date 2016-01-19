-module(server_tcp_echo).
-export([start/0]).

start() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("SERVER Listening on port 2345~n"),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("SERVER Received ~p~n", [Bin]),
            gen_tcp:send(Socket, Bin),
            loop(Socket);
        {tcp_closed, Socket} ->
            io:format("SERVER: The client closed the connection~n")
    end.
