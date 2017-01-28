#!/bin/bash
mysql_install_db --datadir=/var/lib/mysql --user=root:root
mysqld_safe --user=root &
while ! mysqladmin ping --silent; do
    sleep 1s
done
mysql -u root < /usr/local/share/mroonga/install.sql
mysql -u root -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY 'password' WITH GRANT OPTION"
mysql -u root -e "SET PASSWORD FOR root@'%' = ''"
mysqladmin -uroot shutdown