FROM centos:7

ADD MariaDB.repo /etc/yum.repos.d/
RUN yum install -y MariaDB-server-10.1.20 MariaDB-devel-10.1.20 MariaDB-shared-10.1.20

RUN yum install -y http://packages.groonga.org/centos/groonga-release-1.2.0-1.noarch.rpm
RUN yum install -y mecab mecab-ipadic
RUN yum install -y groonga-6.1.3 groonga-devel-6.1.3 groonga-tokenizer-mecab-6.1.3

RUN yum groupinstall -y "Development Tools"
RUN yum install -y clang cmake ncurses-devel
RUN curl -sL https://downloads.mariadb.org/f/mariadb-10.1.20/source/mariadb-10.1.20.tar.gz | tar xz -C /usr/local/src && \
	cd /usr/local/src/mariadb-10.1.20 && \
	CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake . -DENABLE_DTRACE=0 && \
	curl -sL http://packages.groonga.org/source/mroonga/mroonga-6.13.tar.gz | tar xz -C /usr/local/src && \
	cd /usr/local/src/mroonga-6.13 && \
	 ./configure --with-mysql-source=/usr/local/src/mariadb-10.1.20 && \
	make && make install && \
	rm -rf /usr/local/src/*

RUN mysql_install_db --datadir=/var/lib/mysql --user=mysql
RUN mysqld_safe & sleep 10s && \
	mysql -u root < /usr/local/share/mroonga/install.sql && \
	mysql -u root -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'password' WITH GRANT OPTION" && \
	mysql -u root -e "SET PASSWORD FOR root@'%' = ''"

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/root/entrypoint.sh"]
