FROM ecotruck_base

LABEL maintainer="vinh Nguyen (quangvinh68@gmail.vn)"

### update some system configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i 's|session.gc_probability = 0|session.gc_probability = 1|g' /etc/php/7.2/fpm/php.ini

### copy data to container
COPY . /opt

### config ecotruck system
RUN mkdir /run/php /opt/code \
	&& cp /opt/nginx/* /etc/nginx/sites-enabled/

#expose ports and cmd
EXPOSE 80
CMD ["/opt/bin/ecotruck_start.sh"]

