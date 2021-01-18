#
# MailHog Dockerfile
#

FROM alpine:3.12

# Create mailhog user as non-login system user with user-group
COPY --from=mailhog/mailhog:latest /usr/local/bin/MailHog /usr/local/bin

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

