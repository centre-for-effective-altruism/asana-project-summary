FROM alpine

RUN apk --update --no-cache add jq curl postgresql-client

WORKDIR /root

ADD crontab.txt crontab.txt
ADD gettasks.sh gettasks.sh
COPY entrypoint.sh entrypoint.sh
RUN chmod 755 gettasks.sh entrypoint.sh
RUN /usr/bin/crontab crontab.txt

CMD ["./entrypoint.sh"]
