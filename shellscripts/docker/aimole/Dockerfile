FROM node:5

RUN apt-get update && \
	apt-get install -y libsystemd-journal0

VOLUME /app

WORKDIR /app

ENTRYPOINT ["node_modules/.bin/grunt"]
