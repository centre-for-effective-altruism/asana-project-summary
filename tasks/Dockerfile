FROM node:10.15.3-alpine

RUN apk --update --no-cache add jq curl postgresql-client py2-pip

RUN pip install b2

WORKDIR /root

ADD crontab.txt crontab.txt
#ADD gettasks.sh gettasks.sh
ADD pingslack.sh pingslack.sh
ADD package.json package.json
ADD gettasks.js gettasks.js
# TODO; won't cache
RUN yarn install
COPY entrypoint.sh entrypoint.sh
RUN chmod 755 gettasks.sh entrypoint.sh
RUN /usr/bin/crontab crontab.txt

CMD ["./entrypoint.sh"]
