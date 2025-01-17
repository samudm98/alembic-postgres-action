#!/bin/bash
export DB_URI=postgresql://$INPUT_FLYWAY_USER:$INPUT_FLYWAY_PASS@$INPUT_FLYWAY_HOST/ebdb
export SQLALCHEMY_DB_URL=$DB_URI
export PYTHONPATH=.
pip install pipenv
pipenv install --system
pipenv install --dev --system
export OLD_VERSION="$(alembic current | awk '{print $1}' )"
export NEW_VERSION="$(alembic heads | awk '{print $1}')"
echo "$OLD_VERSION ------- $NEW_VERSION"
mkdir -p flyway/sql

if [ "$OLD_VERSION" = "" ];
  then
    echo "FIRST MIGRATION"
    alembic upgrade "$NEW_VERSION" --sql > flyway/sql/Vbo_"$NEW_VERSION".sql

else
  if [ "$OLD_VERSION" = "$NEW_VERSION" ];
  then
    echo "NO MIGRATIONS"
  else
    alembic upgrade "$OLD_VERSION":"$NEW_VERSION"  --sql > flyway/sql/Vbo_"$OLD_VERSION"_"$NEW_VERSION".sql
  fi
fi