alias dflydev-rehash='. $HOME/.dotfiles/.projects.d/dflydev.sh'

alias dflydev-cd='cd $HOME/Code/sites/dflydev'
alias dflydev-project-root='echo $HOME/Code/sites/dflydev'

# Docker Compose
function dflydev-docker-compose() (
    if [ -f '.contrail/docker/.env' ]; then
        DOCKER_COMPOSE_ENV_FILE_OPT="--env-file .contrail/docker/.env"
    fi

    if [ -f ".contrail/docker/docker-compose.override.yaml" ]; then
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p dflydev \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.testing.yaml \
            -f .contrail/docker/docker-compose.testing-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            -f .contrail/docker/docker-compose.override.yaml \
            "$@"
    else
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p dflydev \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.testing.yaml \
            -f .contrail/docker/docker-compose.testing-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            "$@"
    fi
)

# Docker Compose Helpers
alias dflydev-up='dflydev-docker-compose up'
alias dflydev-down='dflydev-docker-compose down'
alias dflydev-restart='dflydev-docker-compose restart'

# Core
alias dflydev-shell='dflydev-docker-compose exec php bash'
alias dflydev-composer='dflydev-docker-compose exec php composer'

# PHP and Composer
alias dflydev-php='dflydev-docker-compose exec php php'
alias dflydev-composer='dflydev-docker-compose exec php composer'
alias dflydev-test-php='dflydev-docker-compose exec php_testing php'

# PHPUnit
alias dflydev-phpunit='dflydev-test-php ./vendor/bin/phpunit'
alias dflydev-phpunit-coverage='dflydev-phpunit --coverage-html=public/coverage'

# Laravel
alias dflydev-artisan='dflydev-php artisan'
alias dflydev-tinker='dflydev-artisan tinker'

# Laravel Testing
alias dflydev-test-artisan='dflydev-test-php artisan --env=testing'

# MySQL
alias dflydev-mysql='dflydev-docker-compose exec -e MYSQL_PWD=password php mysql -h mysql -udflydev dflydev'
alias dflydev-mysqldump='dflydev-docker-compose exec -e MYSQL_PWD=password php mysqldump -h mysql -udflydev dflydev'
alias dflydev-test-mysql='dflydev-docker-compose exec -e MYSQL_PWD=password php_testing mysql -h mysql_testing -udflydev dflydev'
alias dflydev-test-mysqldump='dflydev-docker-compose exec -e MYSQL_PWD=password php_testing mysqldump -h mysql_testing -udflydev dflydev'

function dflydev-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    dflydev-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function dflydev-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    dflydev-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)

function dflydev-test-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    dflydev-test-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function dflydev-test-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    dflydev-test-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)


# blackfire
alias dflydev-blackfire='dflydev-docker-compose exec php blackfire'
alias dflydev-blackfire-run='dflydev-blackfire run'
alias dflydev-blackfire-run-php='dflydev-blackfire-run php -d pcov.enabled=0'
alias dflydev-blackfire-curl='dflydev-blackfire curl'
alias dflydev-test-blackfire='dflydev-docker-compose exec php_testing blackfire'
alias dflydev-test-blackfire-run='dflydev-test-blackfire run'
alias dflydev-test-blackfire-run-php='dflydev-test-blackfire-run php -d pcov.enabled=0'

# Custom
alias dflydev-dusk='dflydev-test-artisan dusk'
alias dflydev-fresh='dflydev-artisan migrate:fresh'
alias dflydev-test-fresh='dflydev-artisan migrate:fresh'
alias dflydev-ide='dflydev-artisan ide-helper:generate && \
dflydev-artisan ide-helper:models -M && \
dflydev-artisan ide-helper:eloquent'
alias dflydev-phpcbf='dflydev-php vendor/bin/phpcbf'
alias dflydev-phpcs='dflydev-php vendor/bin/phpcs'
alias dflydev-psalm='dflydev-php vendor/bin/psalm --no-cache'
alias dflydev-vapor='dflydev-php vendor/bin/vapor'

function dflydev-run {
    FILE="$1"
    shift
    KERNEL=$(cat <<__KERNEL__
require __DIR__ . '/vendor/autoload.php';
\$app = require __DIR__ . '/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require_once '$FILE';
__KERNEL__
)
    dflydev-php -r "$KERNEL" "$@"
}
