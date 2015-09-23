FROM ubuntu:14.04

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install nginx-full lua-cjson
RUN apt-get -y install nginx-extras lua-bitop
ADD srv_router.lua /etc/nginx/srv_router.lua
ADD nginx.conf /etc/nginx/nginx.conf 
RUN mkdir -p /usr/local/share/lua/5.1/resty/dns/
ADD resty/dns/resolver.lua /usr/local/share/lua/5.1/resty/dns/resolver.lua

# ENV NS_IP
# ENV NS_PORT
# ENV TARGET
# ENV DOMAINS
# ENV KEEP_TAGS

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]

