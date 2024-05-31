(lang dune 3.10)

(name yggdrasill)

(license MIT)

(maintainers "Yuki Tajiri <lmdexpr@gmail.com>")
(authors "Yuki Tajiri")
(source (github lmdexpr/yggdrasill))

(generate_opam_files true)

(package
  (name https)
  (synopsis "HTTPS library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    ))

(package
  (name discord)
  (synopsis "Discord library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    yojson
    ppx_yojson_conv
    logs
    hex
    sodium
    ))

(package
  (name minio)
  (synopsis "MinIO library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    yojson
    ppx_yojson_conv
    logs
    ISO8601
    ))

(package
  (name nextcloud)
  (synopsis "Nextcloud library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    yojson
    ppx_yojson_conv
    logs
    ))

(package
  (name elasticmq)
  (synopsis "ElasticMQ library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    yojson
    ppx_yojson_conv
    logs
    ))

(package
  (name nidhoggr)
  (synopsis "Encoder on yggdrasill")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp-eio
    yojson
    ppx_yojson_conv
    logs
    nextcloud
    ))

(package
  (name ratatoskr)
  (synopsis "Discord bot on yggdrasill")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    eio_main
    tls-eio
    ca-certs
    mirage-crypto-rng-eio
    cohttp
    cohttp-eio
    logs
    uri
    http
    discord
    nidhoggr
    ))
