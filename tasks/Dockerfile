FROM alpine

RUN apk --update --no-cache add jq curl postgresql-client py2-pip

RUN pip install b2

WORKDIR /root

ADD crontab.txt crontab.txt
ADD gettasks.sh gettasks.sh
ADD pingslack.sh pingslack.sh
COPY entrypoint.sh entrypoint.sh
RUN chmod 755 gettasks.sh entrypoint.sh
RUN /usr/bin/crontab crontab.txt

CMD ["./entrypoint.sh"]
