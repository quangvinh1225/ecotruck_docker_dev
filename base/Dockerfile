FROM ubuntu:18.04

LABEL maintainer="vinh Nguyen (quangvinh1225@gmail.com)"

# Base ecotruck images
# Install base packages and remove the apt packages cache when done.
# runtime packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        apt-utils \
	openjdk-8-jre \
	nginx \
	libmysqlclient-dev \
	curl \
	memcached \
	rabbitmq-server \
	build-essential \
	python3.6-dev \
	python3.6-distutils \
	python3.6-venv \
	python3.6 \
	php7.2 \
	php7.2-fpm \
	php7.2-mysql \
	php7.2-redis \
	php7.2-curl \
	php7.2-xml \
	&& curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
	&& pip install supervisor uwsgi \
	&& curl -O curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz \
	&& tar xzf elasticsearch-5.6.16.tar.gz && rm elasticsearch-5.6.16.tar.gz \
	&& useradd -r -d /elasticsearch-5.6.16 -M -s /bin/bash elasticsearch \
	&& chown -R elasticsearch:elasticsearch /elasticsearch-5.6.16

# development packages
RUN apt-get install -y \
	inetutils-ping \
	net-tools \
	telnet \
	openssh-server \
	vim \
	git \
	composer \
	npm \
	php7.2-mbstring \
	zip \
	mysql-client

RUN rm -rf /var/lib/apt/lists/*

#expose ports and cmd
EXPOSE 80
CMD ["/bin/bash"]
