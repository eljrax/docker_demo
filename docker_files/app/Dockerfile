FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install curl unzip php5-fpm php5-gd php5-json php5-mysql php5-readline xml-core 
RUN curl -L https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip > /consul.zip
RUN unzip /consul.zip -d /usr/local/bin/
RUN mkdir -p /etc/consul.d
RUN echo '{"service": {"name": "app", "tags": ["demo-app"], "port": 9000}}' >> /etc/consul.d/app.json
RUN sed -i 's/listen = \/var\/run\/php5-fpm\.sock/listen = 9000/g' /etc/php5/fpm/pool.d/www.conf
ADD run.sh /run.sh
CMD /run.sh
