FROM ubuntu:18.04

LABEL maintainer="vinh Nguyen (quangvinh1225@gmail.com)"

# Base ecotruck images
# Install base packages and remove the apt packages cache when done.
# runtime packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
	apt-get install -y \
    apt-utils \
	openjdk-8-jre \
	nginx \
	curl \
	memcached \
	rabbitmq-server \
	mysql-server-5.7 mysql-client \
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
	php7.2-mbstring \
	# Superviser
	&& curl https://bootstrap.pypa.io/get-pip.py | python3.6 \
	&& pip install supervisor uwsgi \
	# Elasticsearch
	&& curl -O curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.6.16.tar.gz \
	&& tar xzf elasticsearch-5.6.16.tar.gz && rm elasticsearch-5.6.16.tar.gz \
	&& useradd -r -d /elasticsearch-5.6.16 -M -s /bin/bash elasticsearch \
	&& chown -R elasticsearch:elasticsearch /elasticsearch-5.6.16
	
	# development packages
RUN apt-get update && apt-get install -y \
	inetutils-ping \
	net-tools \
	telnet \
	openssh-server \
	vim \
	git \
	composer \
	# https://bugs.launchpad.net/ubuntu/+source/nodejs/+bug/1794589/comments/5
	nodejs=8.10.0~dfsg-2ubuntu0.2 nodejs-dev=8.10.0~dfsg-2ubuntu0.2 npm libssl-dev \
	zip \
	libmysqlclient-dev \
	libheif-dev \
	libmagickwand-dev 

RUN apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:strukturag/libde265 \
    && add-apt-repository -y ppa:strukturag/libheif \
    && apt-get install -y libde265-0 libheif1 libheif-dev \
    && npm install npm -g

RUN rm -rf /var/lib/apt/lists/*

	# config sshd for access root without passwd
RUN mkdir /run/sshd \ 
	&& passwd -d root && sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth \
	&& echo "StrictModes no\nPasswordAuthentication yes\nPermitRootLogin yes\nPermitEmptyPasswords yes" >> /etc/ssh/sshd_config \
	# config elasticsearch
	&& sed -i 's|Xms2g|Xms512m|g' /elasticsearch-5.6.16/config/jvm.options \
	&& sed -i 's|Xmx2g|Xmx512m|g' /elasticsearch-5.6.16/config/jvm.options \
	&& echo "network.host: 0.0.0.0\ntransport.host: localhost" >> /elasticsearch-5.6.16/config/elasticsearch.yml \
	# config mysql server
	&& mkdir /var/run/mysqld && chown mysql:mysql /var/run/mysqld \
	&& sed -i 's|127.0.0.1|0.0.0.0|g' /etc/mysql/mysql.conf.d/mysqld.cnf


#expose ports and cmd
EXPOSE 80
CMD ["/bin/bash"]
