#!/bin/bash
if [ ! -e /var/lib/mysql/ibdata1 ] ; then
    init_mariadb.sh
fi

mysqld_safe --user=root