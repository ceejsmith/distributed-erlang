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

partition_for(Bin) ->
    %% TODO: Implement based on path for GET request
    blah.
