alias ninjagrlcom-rehash='. $HOME/.dotfiles/shell/.projects.d/ninjagrlcom'

alias ninjagrlcom-cd='cd $HOME/Code/ninjagrl.com'

# Docker Compose
function ninjagrlcom-docker-compose() (
    if [ -f '.contrail/docker/.env' ]; then
        DOCKER_COMPOSE_ENV_FILE_OPT="--env-file .contrail/docker/.env"
    fi

    if [ -f ".contrail/docker/docker-compose.override.yaml" ]; then
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p ninjagrlcom \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            -f .contrail/docker/docker-compose.override.yaml \
            "$@"
    else
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p ninjagrlcom \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            "$@"
    fi
)

# Docker Compose Helpers
alias ninjagrlcom-up='ninjagrlcom-docker-compose up'
alias ninjagrlcom-down='ninjagrlcom-docker-compose down'
alias ninjagrlcom-restart='ninjagrlcom-docker-compose restart'

# Core
alias ninjagrlcom-shell='ninjagrlcom-docker-compose exec php bash'
alias ninjagrlcom-composer='ninjagrlcom-docker-compose exec php composer'

# PHP and Composer
alias ninjagrlcom-php='ninjagrlcom-docker-compose exec php php'
alias ninjagrlcom-composer='ninjagrlcom-docker-compose exec php composer'
alias ninjagrlcom-test-php='ninjagrlcom-docker-compose exec php_testing php'

# PHPUnit
alias ninjagrlcom-phpunit='ninjagrlcom-test-php ./vendor/bin/phpunit'
alias ninjagrlcom-phpunit-coverage='ninjagrlcom-phpunit --coverage-html=public/coverage'

# Laravel
alias ninjagrlcom-artisan='ninjagrlcom-php artisan'
alias ninjagrlcom-tinker='ninjagrlcom-artisan tinker'

# Laravel Testing
alias ninjagrlcom-test-artisan='ninjagrlcom-test-php artisan --env=testing'

# MySQL
alias ninjagrlcom-mysql='ninjagrlcom-docker-compose exec -e MYSQL_PWD=password php mysql -h mysql -uninjagrlcom ninjagrlcom'
alias ninjagrlcom-mysqldump='ninjagrlcom-docker-compose exec -e MYSQL_PWD=password php mysqldump -h mysql -uninjagrlcom ninjagrlcom'
alias ninjagrlcom-test-mysql='ninjagrlcom-docker-compose exec -e MYSQL_PWD=password php_testing mysql -h mysql_testing -uninjagrlcom ninjagrlcom'
alias ninjagrlcom-test-mysqldump='ninjagrlcom-docker-compose exec -e MYSQL_PWD=password php_testing mysqldump -h mysql_testing -uninjagrlcom ninjagrlcom'

function ninjagrlcom-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    ninjagrlcom-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function ninjagrlcom-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    ninjagrlcom-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)

function ninjagrlcom-test-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    ninjagrlcom-test-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function ninjagrlcom-test-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    ninjagrlcom-test-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)


# Custom
alias ninjagrlcom-fresh='ninjagrlcom-artisan migrate:refresh'
alias ninjagrlcom-ide='ninjagrlcom-artisan ide-helper:generate && \
ninjagrlcom-artisan ide-helper:models -N && \
ninjagrlcom-artisan ide-helper:eloquent'

function ninjagrlcom-run {
    FILE="$1"
    shift
    KERNEL=$(cat <<__KERNEL__
require __DIR__ . '/vendor/autoload.php';
\$app = require __DIR__ . '/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require_once '$FILE';
__KERNEL__
)
    ninjagrlcom-php -r "$KERNEL" "$@"
}
