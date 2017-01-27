#/bin/bash
REQUIRE_PACKAGES="clang gcc-c++ gcc cpp glibc-devel glibc-headers kernel-headers libgomp libmpc mpfr cmake ncurses-devel"

if [ $# -lt 1 ]; then
	echo usage: $0 version 1>&2
	exit 0
fi
MROONGA_VERSION=$1

# Get installed MariaDB version
MARIADB_VERSION=`yum list installed | grep MariaDB-server | head -n 1 | sed -e 's/\s\s*/\t/g' | cut -f2 | cut -d- -f1`
if [ -z "$MARIADB_VERSION" ]; then
	exit 1
fi

# Get installed Groonga version
GROONGA_VERSION=`yum list installed | grep groonga | head -n 1 | sed -e 's/\s\s*/\t/g' | cut -f2 | cut -d- -f1`
if [ -z "$GROONGA_VERSION" ]; then
	exit 1
fi

# Install require package
yum install -y MariaDB-devel-$MARIADB_VERSION groonga-devel-$GROONGA_VERSION $REQUIRE_PACKAGES

# Extract MariaDB source
curl -sL https://downloads.mariadb.org/f/mariadb-$MARIADB_VERSION/source/mariadb-$MARIADB_VERSION.tar.gz | tar xz -C /usr/local/src && cd /usr/local/src/mariadb-$MARIADB_VERSION
if [ $? -ne 0 ]; then
	exit 1
fi
CC=/usr/bin/clang CXX=/usr/bin/clang++ cmake . -DENABLE_DTRACE=0
if [ $? -ne 0 ]; then
	exit 1
fi

# Install Mroonga
curl -sL http://packages.groonga.org/source/mroonga/mroonga-$MROONGA_VERSION.tar.gz | tar xz -C /usr/local/src && cd /usr/local/src/mroonga-$MROONGA_VERSION
if [ $? -ne 0 ]; then
	exit 1
fi
./configure --with-mysql-source=/usr/local/src/mariadb-$MARIADB_VERSION && make && make install
if [ $? -ne 0 ]; then
	exit 1
fi

# Remove source & package
rm -rf /usr/local/src/mariadb-$MARIADB_VERSION /usr/local/src/mroonga-$MROONGA_VERSION
yum remove -y MariaDB-devel groonga-devel $REQUIRE_PACKAGES
