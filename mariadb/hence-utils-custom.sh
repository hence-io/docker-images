# MariaDB Utility functions
PROGRAM_OPTIONS="--defaults-file=$HENCE_APP_DIR/conf/my.cnf --log-error=$HENCE_APP_DIR/logs/mysqld.log --basedir=$HENCE_APP_DIR --datadir=$HENCE_APP_DIR/data --plugin-dir=$HENCE_APP_DIR/lib/plugin --user=$HENCE_APP_USER --socket=$HENCE_APP_DIR/tmp/mysql.sock --lower-case-table-names=1 $EXTRA_OPTIONS"

initialize_database() {
    echo "==> Initializing MySQL database..."
    echo ""
    # mysql_install_db --port=3306 --socket=$HENCE_APP_DIR/tmp/mysql.sock --basedir=$HENCE_APP_DIR --datadir=$HENCE_APP_DIR/data > /dev/null
    mysql_install_db --port=3306 --socket=$HENCE_APP_DIR/tmp/mysql.sock --basedir=/usr --datadir=$HENCE_APP_DIR/data
    chown -R $HENCE_APP_USER:$HENCE_APP_USER $HENCE_APP_DIR/data
}

create_custom_database() {
  if [ "$MARIADB_DATABASE" ]; then
    echo "==> Creating database $MARIADB_DATABASE..."
    echo ""
    echo "CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;" >> /tmp/init_mysql.sql
  fi
}

create_mysql_user() {
  if [ ! "$MARIADB_USER" ]; then
    MARIADB_USER=mysql
  fi

  if [ "$MARIADB_USER" != "root" ] && [ ! $MARIADB_DATABASE ]; then
    echo "In order to use a custom MARIADB_USER you need to provide the MARIADB_DATABASE as well"
    echo ""
    exit -1
  fi

  echo "==> Creating user $MARIADB_USER..."
  echo ""

  echo "DELETE FROM mysql.user ;" >> /tmp/init_mysql.sql
  echo "CREATE USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}' ;" >> /tmp/init_mysql.sql

  if [ "$MARIADB_USER" = root ]; then
    echo "==> Creating root user with unrestricted access..."
    echo "GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;" >> /tmp/init_mysql.sql
  else
    echo "==> Granting access to $MARIADB_USER to the database $MARIADB_DATABASE..."
    echo ""
    echo "GRANT ALL ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%' ;" >> /tmp/init_mysql.sql
  fi

  echo "FLUSH PRIVILEGES ;" >> /tmp/init_mysql.sql
  echo "DROP DATABASE IF EXISTS test ; " >> /tmp/init_mysql.sql
}

print_mysql_password() {
  if [ -z $MARIADB_PASSWORD ]; then
    echo "**none**"
  else
    echo $MARIADB_PASSWORD
  fi
}

print_mysql_database() {
 if [ $MARIADB_DATABASE ]; then
  echo "Database: $MARIADB_DATABASE"
 fi
}
