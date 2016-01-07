FROM node:5

RUN npm install -g grunt-cli
RUN npm install -g coffee-script

VOLUME /app

WORKDIR /app

ENTRYPOINT ["grunt"]
