include:
  - ssl.openssl

erlang:
  pkg.installed:
    - pkgs:
      - dev-lang/erlang: "~19.3[smp,hipe,kpoll,sctp,odbc]"