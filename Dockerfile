FROM --platform=linux/amd64 almalinux:9

ARG mariadb_version="10.11.2"
ARG groonga_version="13.0.1"
ARG mroonga_version="13.01"
ARG TARGETPLATFORM

COPY MariaDB.repo /etc/yum.repos.d/
RUN mkdir /var/lib/mysql \
    && rpm --import https://repo.almalinux.org/almalinux/RPM-GPG-KEY-AlmaLinux-9 \
    && rpm --import https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-9 \
    && rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && rpm --import https://packages.groonga.org/centos/RPM-GPG-KEY-groonga \
    && dnf upgrade -y \
    && dnf install -y https://apache.jfrog.io/artifactory/arrow/almalinux/9/apache-arrow-release-latest.rpm \
    && dnf install -y https://packages.groonga.org/almalinux/9/groonga-release-latest.noarch.rpm \
    && dnf install -y --enablerepo=crb which MariaDB-server-${mariadb_version} MariaDB-client-${mariadb_version}\
    && dnf install -y --enablerepo=crb --enablerepo=epel groonga-${groonga_version} groonga-tokenizer-mecab-${groonga_version} \
    && dnf install -y --enablerepo=crb mariadb-10.11-mroonga-${mroonga_version} \
    && dnf clean all \
    && rm -rf /var/lib/mysql

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  ARCH=amd64  ;; \
         "linux/arm64")  ARCH=arm64  ;; \
         "linux/arm/v7") ARCH=armhf  ;; \
         "linux/arm/v6") ARCH=armel  ;; \
         "linux/386")    ARCH=i386   ;; \
    esac \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys  B42F6819007F00F88E364FD4036A9C25BF357DD4\
    && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.14/gosu-${ARCH}" \
    && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.14/gosu-${ARCH}.asc" \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm /usr/local/bin/gosu.asc \
    && rm -rf /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

VOLUME /var/lib/mysql

COPY --chmod=0755 docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
