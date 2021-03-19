FROM alpine as bin

ARG TARGETARCH
ARG BUILDPLATFORM

ADD https://packages.blackfire.io/binaries/blackfire/2.0.0-beta2/blackfire-linux_$TARGETARCH /usr/local/bin/blackfire
RUN chmod 0555 /usr/local/bin/blackfire

FROM alpine

ARG BUILDPLATFORM

ENV BLACKFIRE_CONFIG /dev/null
ENV BLACKFIRE_LOG_LEVEL 1
ENV BLACKFIRE_SOCKET tcp://0.0.0.0:8307
EXPOSE 8307

RUN apk add --no-cache curl socat \
 && addgroup -S blackfire \
 && adduser -S -H -G blackfire -u 999 blackfire

COPY entrypoint.sh /usr/local/bin/
COPY --from=bin /usr/local/bin/blackfire /usr/local/bin/blackfire

# Don't run as root
USER blackfire

CMD ["blackfire", "agent:start"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
