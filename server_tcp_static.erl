-module(server_tcp_static).
-export([start/1]).

start(Response) ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("Listening on port 2345~n"),
    accept(Listen, Response).

accept(Listen, Response) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    respond(Socket, Response),
    accept(Listen, Response).

respond(Socket, Response) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Received: ~p~n", [Bin]),
            gen_tcp:send(Socket, Response),
            respond(Socket, Response);
        {tcp_closed, Socket} ->
            io:format("The client closed the connection~n")
    end.
