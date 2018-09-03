FROM groovy
LABEL maintainer="Amit Kshirsagar <amit.kshirsagar.13@gmail.com>"

RUN apk add gettext libintl &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst \
    && apk del gettext