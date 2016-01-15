-module(server_hello).
-compile(export_all).

start() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
	    io:format("Received data ~p~n", [Bin]),
	    gen_tcp:send(Socket, "HTTP/1.1 200 OK\r\nContent-Length: 12\r\nContent-Type: text/plain\r\n\r\nHello World!"),
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("Socket closed~n")
    end.
