(lang dune 3.16)

(name yggdrasill)

(license MIT)

(maintainers "Yuki Tajiri <lmdexpr@gmail.com>")
(authors "Yuki Tajiri")
(source (github lmdexpr/yggdrasill))

(generate_opam_files true)

(pin
  (url "git+https://github.com/ahrefs/ocaml-sodium#734eccbb47e7545a459a504188f1da8dc0bd018e")
  (package (name sodium))
 )

(pin
  (url "git+https://github.com/lmdexpr/discord.ml#6f38cfc7e410de4db616c225a52c00e3b2f60398")
  (package (name discord))
 )

(package
  (name httpx)
  (synopsis "HTTP wrapper")
  (depends
    (ocaml (>= 5.3))
    eio
    tls-eio
    ca-certs
    cohttp-eio
    uri
    http
    logs
    ))

(package
  (name minio)
  (synopsis "MinIO library")
  (depends
    (ocaml (>= 5.3))
    cohttp-eio
    digestif
    uri
    yojson
    ppx_yojson_conv
    ISO8601
    logs
    ))

(package
  (name nextcloud)
  (synopsis "Nextcloud library")
  (depends
    dune
    (ocaml (>= 5.3))
    eio
    httpx
    logs
    ))

(package
  (name elasticmq)
  (synopsis "ElasticMQ library")
  (depends
    (ocaml (>= 5.3))
    cohttp-eio
    digestif
    yojson
    ppx_yojson_conv
    logs
    httpx
    ))

(package
  (name nidhoggr)
  (synopsis "Encoder on yggdrasill")
  (depends
    (ocaml (>= 5.3))
    eio 
    httpx
    discord
    nextcloud
    logs
    ))

(package
  (name ratatoskr)
  (synopsis "Discord bot on yggdrasill")
  (depends
    (dune (< 3.17))
    (ocaml (>= 5.3))
    eio
    eio_main
    mirage-crypto-rng-eio
    logs
    uri
    httpx
    discord
    nidhoggr
    ))
