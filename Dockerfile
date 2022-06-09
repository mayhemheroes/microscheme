FROM --platform=linux/amd64 ubuntu:20.04 as builder

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential xxd

ADD . /repo
WORKDIR /repo
RUN make -j8 hexify
RUN make -j8 build

RUN mkdir -p /deps
RUN ldd /repo/microscheme | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'cp % /deps;'

FROM ubuntu:20.04 as package

COPY --from=builder /deps /deps
COPY --from=builder /repo/microscheme /repo/microscheme
ENV LD_LIBRARY_PATH=/deps
