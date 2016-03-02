#@IgnoreInspection BashAddShebang
FROM debian:jessie

MAINTAINER Franz Josef Kaiser <wecodemore@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.9.10-1~jessie
ENV TIMEZONE Europe/Vienna

# @TODO NGX_PAGESPEED https://github.com/yappabe/docker-nginx/blob/master/1.9-pagespeed/Dockerfile

# Install nginx, reduce image size
# Remove man pages
# (not yet) Exchange full i18n with English-only debconf
# Remove not needed APT lists and temp files
RUN apt-key adv \
		--keyserver hkp://pgp.mit.edu:80 \
		--recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y -q --no-install-recommends \
		lsb-release \
		ca-certificates \
		nginx=${NGINX_VERSION} \
		gettext-base \
	&& apt-get clean \
	&& rm -rf /usr/share/man/?? \
		/usr/share/man/??_* \
		/var/lib/apt/lists/* \
		/tmp/* \
		/var/tmp/*

# Sets timezone
# Add logs folder for nginx
# Forward request and error logs to docker log collector
RUN echo ${TIMEZONE} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Add Logs directory
# Symlink StdOut/StdErr to files for use in volumes
RUN mkdir /etc/nginx/logs \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /var/cache/nginx/temp

# Add available and enabled sites dir
# Symlink all available sites to enable them
RUN mkdir /etc/nginx/sites-available/ \
	&& ln -sf /etc/nginx/sites-available/ /etc/nginx/sites-enabled

VOLUME [ "/var/www", "/var/log/nginx" , "/etc/nginx" ]

#WORKDIR /etc/nginx

EXPOSE 80

CMD [ "nginx", "-g", "daemon off;" ]