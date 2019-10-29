FROM ecotruck_base

LABEL maintainer="vinh Nguyen (quangvinh1225@gmail.com)"

### update some system configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
	sed -i 's|session.gc_probability = 0|session.gc_probability = 1|g' /etc/php/7.2/fpm/php.ini

### copy data to container
COPY . /opt

### config system
RUN mkdir /run/sshd /var/log/uwsgi /var/log/supervisord /opt/development \
	&& cp /opt/nginx/* /etc/nginx/sites-enabled/ \
	&& passwd -d root && sed -i 's/nullok_secure/nullok/' /etc/pam.d/common-auth \
	&& echo "StrictModes no\nPasswordAuthentication yes\nPermitRootLogin yes\nPermitEmptyPasswords yes" >> /etc/ssh/sshd_config \
	&& ln -s /opt/supervisor/supervisord.conf /etc/supervisord.conf \
	&& sed -i 's|Xms2g|Xms512m|g' /elasticsearch-5.6.16/config/jvm.options && sed -i 's|Xmx2g|Xmx512m|g' /elasticsearch-5.6.16/config/jvm.options

#expose ports and cmd
EXPOSE 80
CMD ["/opt/bin/ecotruck_start.sh"]

