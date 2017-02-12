FROM centos:7

COPY MariaDB.repo /etc/yum.repos.d/
RUN yum install -y http://packages.groonga.org/centos/groonga-release-1.2.0-1.noarch.rpm
RUN yum install -y MariaDB-server-10.1.21 groonga-7.0.0 groonga-tokenizer-mecab-7.0.0

COPY install_mroonga.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install_mroonga.sh && /usr/local/bin/install_mroonga.sh 7.00

COPY init_mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_mariadb.sh && /usr/local/bin/init_mariadb.sh

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/root/entrypoint.sh"]
