FROM centos:8

ARG mariadb_version="10.5.5"
ARG groonga_version="10.0.6"
ARG mroonga_version="10.06"

COPY MariaDB.repo /etc/yum.repos.d/
RUN mkdir /var/lib/mysql \
    && rpm --import https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official \
    && rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 \
    && rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && rpm --import https://packages.groonga.org/centos/RPM-GPG-KEY-groonga \
    && dnf upgrade -y \
    && dnf install -y https://packages.groonga.org/centos/groonga-release-latest.noarch.rpm \
    && dnf install -y which MariaDB-server-${mariadb_version} MariaDB-client-${mariadb_version} groonga-${groonga_version} groonga-tokenizer-mecab-${groonga_version} mariadb-10.5-mroonga-${mroonga_version} \
    && dnf clean all \
    && rm -rf /var/lib/mysql

RUN gpg --batch --keyserver keys.gnupg.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64.asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && rm -rf /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

VOLUME /var/lib/mysql

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
RUN chmod +rx /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
