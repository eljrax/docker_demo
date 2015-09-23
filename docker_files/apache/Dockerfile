FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN sed -i 's/main\ restricted/main\ restricted\ multiverse/g' /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install apache2 libapache2-mod-fastcgi unzip curl supervisor
RUN curl -L https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip > /consul.zip
RUN unzip /consul.zip -d /usr/local/bin/
RUN mkdir -p /etc/consul.d
RUN echo '{"service": {"name": "web", "tags": ["demo-app"], "port": 80}}' >> /etc/consul.d/web.json
ADD run.sh /run.sh
ADD vhost.conf /etc/apache2/sites-available/vhost.conf
RUN a2dissite 000-default
RUN a2ensite vhost
RUN a2enmod proxy
RUN a2enmod proxy_fcgi
CMD /run.sh
