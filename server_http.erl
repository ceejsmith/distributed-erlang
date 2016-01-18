-module(server_http).
-export([start/0]).

%% This server only stays alive for one connection, but this is OK for demonstration in a modern
%% browser, since HTTP 1.1 keeps the connection open for multiple requests.

start() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    io:format("Listening on port 2345~n"),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Received request~n"),
            Host = host_for(Bin),
            io:format("Chose host ~p~n", [Host]),
	    spawn(fun () -> respond(Host, Socket) end),
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("The client closed the connection~n")
    end.

%% Paths beginning in the first half of the alphabet go to the first back end node
%% The second half go to the second back end node
host_for(Bin) ->
    [Line|_] = string:tokens(binary_to_list(Bin), "\r\n"), %% First line is the GET request
    Code = lists:nth(6, Line), %% "GET /" are the first 5 characters
    if
        Code > 64, Code < 78 -> "first"; %% A - M
	Code > 96, Code < 110 -> "first"; %% a - m
	Code > 77, Code < 91 -> "second"; %% N - Z
	Code > 109, Code < 123 -> "second"; %% n - z
	true -> "error"
    end.

respond(Host, ResponseSocket) ->
    {ok, RequestSocket} = gen_tcp:connect(Host, 2345, [binary, {packet, 0}]),
    ok = gen_tcp:send(RequestSocket, "ping"),
    io:format("Sent request to back end~n"),
    receive
        {tcp, RequestSocket, Bin} ->
            Response = plain_text_response(binary_to_list(Bin)),
            gen_tcp:send(ResponseSocket, Response)
    end.

plain_text_response(Text) ->
    Length = integer_to_list(string:len(Text)),
    "HTTP/1.1 200 OK\r\nContent-Length: " ++ Length ++ "\r\nContent-Type: text/plain\r\n\r\n" ++ Text.
