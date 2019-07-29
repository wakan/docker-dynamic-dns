FROM alpine
RUN apk update && apk add bash wget
COPY pool.sh /pool.sh
CMD /bin/bash /pool.sh
