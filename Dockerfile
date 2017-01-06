FROM debian:stretch-slim

# install mongo-tools, curl  and jq
RUN apt-get update && apt-get install -y \
  mongo-tools=3.2.* \
  curl=7.51.* \
  jq=1.5+dfsg-1.1 \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /osem-archiver
WORKDIR /osem-archiver

COPY . /osem-archiver

ENTRYPOINT ["./archive.sh"]
