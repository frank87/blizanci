%% blizanci, a Gemini protocol server, by Martin Keegan
%%
%% To the extent (if any) permissible by law, Copyright (C) 2020  Martin Keegan
%%
%% This programme is free software; you may redistribute and/or modify it under
%% the terms of the Apache Software Licence v2.0.

-module(blizanci_config).

-export([ssl_opts/0, proto_opts/0]).

-define(PORT, 1965).

ssl_opts() ->
    {ok, App} = application:get_application(),
    Cert = application:get_env(App, certfile, "./ssl/certificate.pem"),
    Key = application:get_env(App, keyfile, "./ssl/key.pem"),
    Port = application:get_env(App, port, ?PORT),
    VerifyFn = fun (ClientCert, Ev, Init) ->
                   blizanci_gemini:verify_cert(ClientCert, Ev, Init) end,

    [{port, Port},
     {certfile, Cert},
     {keyfile, Key},
     {verify, verify_peer},
     {cacertfile, "/dev/null"},
     {verify_fun, {VerifyFn, []}}
    ].

proto_opts() ->
    {ok, App} = application:get_application(),
    {ok, Default_Hostname} = inet:gethostname(),
    Hostname = application:get_env(App, hostname, Default_Hostname),
    Docroot = application:get_env(App, docroot, "./public_gemini"),
    CGIroot = application:get_env(App, cgiroot, "./cgi-bin"),
    Port = application:get_env(App, port, ?PORT),

    [{hostname, Hostname},
     {docroot, Docroot},
     {cgiroot, CGIroot},
     {port, Port}
    ].
