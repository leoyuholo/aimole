FROM node:6

RUN git config --system user.name Docker && git config --system user.email docker@localhost

VOLUME /app

WORKDIR /app

ENTRYPOINT ["npm", "run"]
