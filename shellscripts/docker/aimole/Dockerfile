FROM node:5

RUN git config --system user.name Docker && git config --system user.email docker@localhost

VOLUME /app

WORKDIR /app

ENTRYPOINT ["node_modules/.bin/grunt"]
