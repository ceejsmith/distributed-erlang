-module(client_tcp).
-export([send/1]).

send(Str) ->
    {ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, Str),
    receive
        {tcp, Socket, Bin} ->
            io:format("Received: ~p~n", [Bin]),
            gen_tcp:close(Socket)
    end.
