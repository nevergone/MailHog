#
# MailHog Dockerfile
#

FROM golang:alpine as builder

# Install MailHog:
RUN apk --no-cache add --virtual build-dependencies \
    git \
  && mkdir -p /root/gocode \
  && export GOPATH=/root/gocode \
  && go get github.com/nevergone/MailHog \
  && mv /root/gocode/bin/MailHog /usr/local/bin \
  && rm -rf /root/gocode \
  && apk del --purge build-dependencies

## create destination image
FROM alpine:3.12

# Create mailhog user as non-login system user with user-group
COPY --from=builder /usr/local/bin/MailHog /usr/local/bin

ARG USERNAME=mailhog
RUN apk update \
    && apk upgrade \
    && apk add --no-cache \
       libcap \
       shadow \
    && useradd --shell /bin/false -Urb / -u 1000 ${USERNAME} \
    && echo ${USERNAME} > /.unpriv_username \
    && setcap 'cap_net_bind_service=+ep' /usr/local/bin/MailHog

# Expose the SMTP and HTTP ports:
EXPOSE 1025 8025
WORKDIR /
USER ${USERNAME}

CMD ["/usr/local/bin/MailHog"]

