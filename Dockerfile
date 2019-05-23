FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

#add openxpki signing key to apt
RUN apt-get update \
    && apt-get install -y wget \
    && wget http://packages.openxpki.org/debian/Release.key -O - | apt-key add -

#add sources
RUN echo "deb http://packages.openxpki.org/debian/ jessie release" > /etc/apt/sources.list.d/openxpki.list \
    && echo "deb http://httpredir.debian.org/debian jessie non-free" >> /etc/apt/sources.list

#do locale bootstrap
RUN apt-get update \
    && apt-get install -y locales \
      libdbd-mysql-perl \
      libapache2-mod-fcgid \
      libopenxpki-perl \
      openxpki-i18n \
      openca-tools \
      mysql-client \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


ADD scripts/importdb.sh /usr/local/bin/importdb.sh
RUN chmod +x /usr/local/bin/importdb.sh
#RUN [ "/usr/local/bin/importdb.sh" ]
#RUN [ "mysql", "-u", "root", "--password", "password", "openxpki", "<", "/usr/local/database.sql" ]
 
# turn on apache fastcgi
RUN a2enmod fcgid

ADD config/database.yaml /etc/openxpki/config.d/system/database.yaml
ADD config/openxpki-apache.conf /etc/apache2/conf-enabled/openxpki.conf
ADD scripts/sampleconfig.sh /usr/share/doc/libopenxpki-perl/examples/sampleconfig.sh
RUN chmod 755 /usr/share/doc/libopenxpki-perl/examples/sampleconfig.sh

ADD scripts/launch.sh /usr/local/bin/launch.sh
RUN chmod 755 /usr/local/bin/launch.sh
CMD [ "/bin/bash", "/usr/local/bin/launch.sh" ]
