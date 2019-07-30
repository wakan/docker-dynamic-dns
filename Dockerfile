FROM alpine
LABEL maintainer="wakan_powa_s01@hotmail.fr"
RUN apk update && apk add bash curl
COPY pool.sh /pool.sh
CMD /bin/bash /pool.sh
