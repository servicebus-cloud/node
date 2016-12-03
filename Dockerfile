# Zato server

FROM ubuntu:14.04
MAINTAINER Rafał Krysiak <rafal@zato.io>

RUN ln -s -f /bin/true /usr/bin/chfn

# Install helper programs used during Zato installation
RUN apt-get update && apt-get install -y apt-transport-https \
    python-software-properties \
    software-properties-common \
    curl \
    telnet \
    nano \
    wget

# Add the package signing key
RUN curl -s https://zato.io/repo/zato-0CBD7F72.pgp.asc | sudo apt-key add -

# Add Zato repo to your apt
# update sources and install Zato
RUN apt-add-repository https://zato.io/repo/stable/2.0/ubuntu
RUN apt-get update && apt-get install -y zato

USER zato
WORKDIR /opt/zato

EXPOSE 17010

RUN mkdir /opt/zato/ca
COPY certs/zato.server1.cert.pem /opt/zato/ca/
COPY certs/zato.server1.key.pem /opt/zato/ca/
COPY certs/zato.server1.key.pub.pem /opt/zato/ca/
COPY certs/ca_cert.pem /opt/zato/ca/
COPY zato_server.config /opt/zato/

COPY zato_start_server /opt/zato/zato_start_server
COPY zato_from_config_create_server /opt/zato/zato_from_config_create_server

USER root
RUN chmod 755 /opt/zato/zato_start_server \
              /opt/zato/zato_from_config_create_server


USER zato
RUN rm -rf /opt/zato/env/server && mkdir -p /opt/zato/env/server

CMD ["/opt/zato/zato_start_server"]
