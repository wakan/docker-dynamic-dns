FROM alpine
RUN apk update && apk add bash curl
COPY pool.sh /pool.sh
CMD /bin/bash /pool.sh
