%% blizanci, a Gemini protocol server, by Martin Keegan
%%
%% To the extent (if any) permissible by law, Copyright (C) 2022  Martin Keegan
%%
%% This programme is free software; you may redistribute and/or modify it under
%% the terms of the Apache Software Licence v2.0.

-module(blizanci_auth).
-include("blizanci_types.hrl").

-export([authorisation_policy/1, authorised/2]).

-spec authorisation_policy(map()) ->
          {'ok', authorisation()} | {'error', atom()}.
authorisation_policy(Options) when is_map(Options) ->
    #{ authorisation := Auth } = Options,
    valid_authz_policy(Auth).

valid_authz_policy(public) -> {ok, public};
valid_authz_policy(restricted) -> {ok, restricted};
valid_authz_policy(private) -> {ok, private};
valid_authz_policy(_) -> {error, invalid_authz_policy}.

-spec authorised(authorisation(), map()) ->
          'authorised' | {'error_code', atom()}.
authorised(public, _Request) -> authorised;
authorised(AuthPolicy, Request) ->
    CertInfo = client_cert_info(Request),
    cert_authorised(AuthPolicy, CertInfo).

cert_authorised(_, error) ->
    {error_code, cert_required};
cert_authorised(restricted, {ok, Cert}) ->
    lager:info("Cert required: ~p", [Cert]),
    authorised;
cert_authorised(private, {ok, Cert}) ->
    #{ common_name := Subject,
       issuer_common_name := Issuer } = Cert,
    lager:info("object requested, cert: ~p/~p", [Subject, Issuer]),
    authorised.


client_cert_info(Request) ->
    #{ client_cert := Cert } = Request,
    blizanci_x509:peercert_cn(Cert).
