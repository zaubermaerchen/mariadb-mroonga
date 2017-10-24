# mariadb-mroonga

## Quick Start

    $ sudo docker build -t REPOSITORY .
    $ sudo docker run -e MYSQL_ROOT_PASSWORD=PASSWORD -d -p 13306:3306 REPOSITORY
    $ mysql --user=root --password=PASSWORD --host=127.0.0.1 --port=13306 REPOSITORY



## Version

| MariaDB | Groonga | Mroonga |
|---------|---------|---------|
| 10.2.9  | 7.0.7   | 7.07    |