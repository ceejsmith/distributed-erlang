-module(server_hello).
-export([start/0]).

start() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 0}, {reuseaddr, true}, {active, true}]),
    {ok, Socket} = gen_tcp:accept(Listen),
    gen_tcp:close(Listen),
    loop(Socket).

loop(Socket) ->
    receive
        {tcp, Socket, Bin} ->
	    Text = atom_to_list(partition_for(Bin)),
	    gen_tcp:send(Socket, plain_text_response(Text)),
	    loop(Socket);
	{tcp_closed, Socket} ->
	    io:format("Socket closed~n")
    end.

plain_text_response(Text) ->
    Length = integer_to_list(string:len(Text)),
    "HTTP/1.1 200 OK\r\nContent-Length: " ++ Length ++ "\r\nContent-Type: text/plain\r\n\r\n" ++ Text.

%% Paths beginning in the first half of the alphabet go to the first back end node
%% The second half go to the second back end node
partition_for(Bin) ->
    [Line|_] = string:tokens(binary_to_list(Bin), "\r\n"), %% First line is the GET request
    Code = lists:nth(6, Line), %% "GET /" are the first 5 characters
    if
        Code > 64, Code < 78 -> first; %% A - M
	Code > 96, Code < 110 -> first; %% a - m
	Code > 77, Code < 91 -> second; %% N - Z
	Code > 109, Code < 123 -> second; %% n - z
	true -> error
    end.
