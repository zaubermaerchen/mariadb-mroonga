FROM centos:7

ARG mariadb_version="10.3.9"
ARG groonga_version="8.0.8"
ARG mroonga_version="8.07"

COPY MariaDB.repo /etc/yum.repos.d/
RUN mkdir /var/lib/mysql \
    && rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && yum upgrade -y \
    && yum install -y http://packages.groonga.org/centos/groonga-release-1.4.0-1.noarch.rpm \
    && yum install -y MariaDB-server-${mariadb_version} MariaDB-client-${mariadb_version} groonga-${groonga_version} groonga-tokenizer-mecab-${groonga_version} mariadb-10.3-mroonga-${mroonga_version} \
    && yum clean all \
    && rm -rf /var/lib/mysql

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN chmod +rx /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
