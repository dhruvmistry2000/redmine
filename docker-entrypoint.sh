#!/bin/bash
set -e

###############################################################################
# 1. Generate config/database.yml for PostgreSQL
###############################################################################
cat > config/database.yml <<EOF
production:
  adapter: postgresql
  database: ${REDMINE_DB_DATABASE:-redmine}
  host: ${REDMINE_DB_HOST:-postgres}
  username: ${REDMINE_DB_USERNAME:-redmine}
  password: ${REDMINE_DB_PASSWORD:-password}
  port: ${REDMINE_DB_PORT:-5432}
  encoding: unicode
EOF

echo "✅ Generated database.yml:"
cat config/database.yml

###############################################################################
# 2. Install main Redmine dependencies
###############################################################################
echo "📦 Installing Redmine gems..."
bundle config set without 'development test'
bundle install

###############################################################################
# 3. Optionally install plugin-specific Gemfiles
###############################################################################
for plugin in plugins/*; do
  if [ -f "$plugin/Gemfile" ]; then
    echo "📦 Installing gems for plugin: $plugin"
    bundle config set --local gemfile "$plugin/Gemfile"
    bundle install || true
    bundle config unset gemfile
  fi
done

###############################################################################
# 4. Core Redmine migrations
###############################################################################
echo "🛠 Running core Redmine migrations..."
bundle exec rake db:migrate RAILS_ENV=production

###############################################################################
# 5. Plugin migrations (optional)
###############################################################################
if [ "${REDMINE_PLUGINS_MIGRATE}" = "true" ]; then
  echo "⚙️ Running plugin migrations..."
  bundle exec rake redmine:plugins:migrate RAILS_ENV=production
else
  echo "🚫 Skipping plugin migrations."
fi

###############################################################################
# 6. Hand control to the container’s CMD
###############################################################################
exec "$@"
