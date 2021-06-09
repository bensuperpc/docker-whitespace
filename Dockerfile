ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache bison flex gcc make musl-dev git \
	&& git clone --recurse-submodules https://github.com/rdebath/whitespace.git
WORKDIR /whitespace

RUN make all -j$(nproc)

RUN mkdir -p /usr/local/bin
RUN cp wsc /usr/local/bin
RUN cp wsa /usr/local/bin
RUN cp ws2c /usr/local/bin
RUN cp blockquote /usr/local/bin
ENV PATH="/usr/local/bin:${PATH}"

COPY hello.ws .
RUN ws2c hello.ws

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add --no-cache musl-dev make

COPY --from=builder /usr/local /usr/local

ENV PATH="/usr/local/bin:${PATH}"

ENV CC=/usr/local/bin/whitespace
WORKDIR /usr/src/myapp

CMD ["ws2c", ""]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/whitespace" \
	  org.label-schema.description="build whitespace compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-whitespace" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/whitespace -f Dockerfile ."
