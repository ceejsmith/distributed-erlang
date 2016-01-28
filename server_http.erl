-module(server_http).
-export([start/0]).

%% This server only stays alive for one connection, but this is OK for demonstration in a modern
%% browser, since HTTP 1.1 keeps the connection open for multiple requests.

start() ->
    {ok, Listen} = gen_tcp:listen(2345, [ binary
                                        , {packet, 0}
                                        , {reuseaddr, true}
                                        , {active, true}
                                        ]),
    io:format("SERVER Listening on port 2345\n"),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("SERVER Received request\n"),
            Host = host_for(Bin),
            io:format("SERVER Chose host ~p\n", [Host]),
	    spawn(fun () -> respond(Host, Socket) end),
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("SERVER: The client closed the connection\n")
    end.

%% Paths beginning in the first half of the alphabet go to the first back end node
%% The second half go to the second back end node
host_for(<<"GET /", FirstChar:1/binary, _Rest/binary>>) ->
    Char = string:to_upper(binary:first(FirstChar)),
    case Char of
        _ when Char >= $A, Char =< $M -> "first";
        _ when Char >= $N, Char =< $Z -> "second";
        _ -> "error"
    end.

respond(Host, ResponseSocket) ->
    {ok, RequestSocket} = gen_tcp:connect(Host, 2345, [binary, {packet, 0}]),
    ok = gen_tcp:send(RequestSocket, "ping"),
    io:format("SERVER Sent request to back end\n"),
    receive
        {tcp, RequestSocket, Bin} ->
            Response = plain_text_response(Bin),
            io:format("SERVER Sent HTTP response: ~s\n", [Response]),
            gen_tcp:send(ResponseSocket, Response)
    end.

plain_text_response(Text) ->
    Length = integer_to_list(byte_size(Text)),
    ["HTTP/1.1 200 OK\r\nContent-Length: ", Length, "\r\nContent-Type: text/plain\r\n\r\n", Text].
