FROM ocaml/opam:alpine AS init-opam

RUN set -x && \
    : "Update and upgrade default packagee" && \
    sudo apk update && sudo apk upgrade && \
    sudo apk add bash git libsodium-dev

FROM init-opam AS ocaml-app-base
COPY . .
RUN set -x && \
    : "Install related pacakges" && \
    opam-2.1 install . --deps-only --locked

RUN set -x && \
    eval $(opam-2.1 env) && \
    : "Build applications" && \
    dune build && \
    sudo cp -r ./_build/default /usr/bin/app

FROM alpine AS ocaml-app

COPY --from=ocaml-app-base /usr/bin/app/ratatoskr/ratatoskr.exe /home/app/ratatoskr
RUN set -x && \
    : "Update and upgrade default packagee" && \
    apk update && apk upgrade && \
    apk add gmp libsodium ffmpeg unzip && \
    : "Create a user to execute application" && \
    adduser -D app && \
    : "Change owner to app" && \
    chown app:app /home/app/ratatoskr

WORKDIR /home/app
USER app
ENTRYPOINT /home/app/ratatoskr
