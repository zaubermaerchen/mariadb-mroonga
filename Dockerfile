FROM centos:7

ARG mariadb_version="10.3.17"
ARG groonga_version="9.0.5"
ARG mroonga_version="9.05"

COPY MariaDB.repo /etc/yum.repos.d/
RUN mkdir /var/lib/mysql \
    && rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-7 \
    && rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 \
    && rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && rpm --import https://packages.groonga.org/centos/RPM-GPG-KEY-groonga \
    && yum upgrade -y \
    && yum install -y https://packages.groonga.org/centos/groonga-release-latest.noarch.rpm \
    && yum install -y which MariaDB-server-${mariadb_version} MariaDB-client-${mariadb_version} groonga-${groonga_version} groonga-tokenizer-mecab-${groonga_version} mariadb-10.3-mroonga-${mroonga_version} \
    && yum clean all \
    && rm -rf /var/lib/mysql

RUN gpg --batch --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64.asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
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
