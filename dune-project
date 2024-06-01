(lang dune 3.10)

(name yggdrasill)

(license MIT)

(maintainers "Yuki Tajiri <lmdexpr@gmail.com>")
(authors "Yuki Tajiri")
(source (github lmdexpr/yggdrasill))

(generate_opam_files true)

(package
  (name httpx)
  (synopsis "HTTP wrapper")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    tls-eio
    ca-certs
    cohttp-eio
    uri
    http
    logs
    ))

(package
  (name discord)
  (synopsis "Discord library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    yojson
    ppx_yojson_conv
    logs
    hex
    sodium
    httpx
    ))

(package
  (name minio)
  (synopsis "MinIO library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    yojson
    ppx_yojson_conv
    logs
    ISO8601
    httpx
    ))

(package
  (name nextcloud)
  (synopsis "Nextcloud library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    httpx
    logs
    ))

(package
  (name elasticmq)
  (synopsis "ElasticMQ library")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    yojson
    ppx_yojson_conv
    logs
    httpx
    ))

(package
  (name nidhoggr)
  (synopsis "Encoder on yggdrasill")
  (depends
    (dune (>= 3.10))
    (ocaml (>= 5.1))
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
    (dune (>= 3.10))
    (ocaml (>= 5.1))
    eio
    logs
    uri
    httpx
    discord
    nidhoggr
    ))
