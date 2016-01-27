-module(server_tcp_static).
-export([start/1]).

start([Response]) ->
    io:format("SERVER Trying to bind to port 2345\n"),
    {ok, Listen} = gen_tcp:listen(2345, [ binary
                                        , {packet, 0}
                                        , {reuseaddr, true}
                                        , {active, true}
                                        ]),
    io:format("SERVER Listening on port 2345\n"),
    accept(Listen, Response).

accept(Listen, Response) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    respond(Socket, Response),
    accept(Listen, Response).

respond(Socket, Response) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("SERVER Received: ~p\n", [Bin]),
            gen_tcp:send(Socket, Response),
            respond(Socket, Response);
        {tcp_closed, Socket} ->
            io:format("SERVER: The client closed the connection\n")
    end.
