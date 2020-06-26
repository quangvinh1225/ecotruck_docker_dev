FROM quangvinh1225/ecotruck_base

LABEL maintainer="vinh Nguyen (quangvinh1225@gmail.com)"
	
### copy data to container
COPY . /opt

### config system
RUN mkdir /var/log/uwsgi /var/log/supervisord /opt/ecotruck \
	&& cp /opt/nginx/* /etc/nginx/sites-enabled/ \
	&& ln -s /opt/supervisor/supervisord.conf /etc/supervisord.conf \
	&& echo "daemon off;" >> /etc/nginx/nginx.conf \
	&& sed -i 's|session.gc_probability = 0|session.gc_probability = 1|g' /etc/php/7.2/fpm/php.ini \
	&& sed -i 's|/var/lib/mysql|/opt/ecotruck/mysqldata|g' /etc/mysql/mysql.conf.d/mysqld.cnf

#expose ports and cmd
EXPOSE 80
CMD ["/opt/bin/start.sh"]

