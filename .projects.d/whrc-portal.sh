alias whrc-portal-rehash='. $HOME/.dotfiles/.projects.d/whrc-portal.sh'

alias whrc-portal-cd='cd $HOME/Code/sites/whrc-portal'
alias whrc-portal-project-root='echo $HOME/Code/sites/whrc-portal'

# Docker Compose
function whrc-portal-docker-compose() (
    if [ -f '.contrail/docker/.env' ]; then
        DOCKER_COMPOSE_ENV_FILE_OPT="--env-file .contrail/docker/.env"
    fi

    if [ -f ".contrail/docker/docker-compose.override.yaml" ]; then
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p whrc-portal \
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
            -p whrc-portal \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.testing.yaml \
            -f .contrail/docker/docker-compose.testing-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            "$@"
    fi
)

# Docker Compose Helpers
alias whrc-portal-up='whrc-portal-docker-compose up'
alias whrc-portal-down='whrc-portal-docker-compose down'
alias whrc-portal-restart='whrc-portal-docker-compose restart'

# Core
alias whrc-portal-shell='whrc-portal-docker-compose exec php bash'
alias whrc-portal-composer='whrc-portal-docker-compose exec php composer'

# Core (test)
alias whrc-portal-test-shell='whrc-portal-docker-compose exec php_testing bash'
alias whrc-portal-test-composer='whrc-portal-docker-compose exec php_testing composer'

# PHP and Composer
alias whrc-portal-php='whrc-portal-docker-compose exec php php'
alias whrc-portal-composer='whrc-portal-docker-compose exec php composer'
alias whrc-portal-test-php='whrc-portal-docker-compose exec php_testing php'

# PHPUnit
alias whrc-portal-phpunit='whrc-portal-test-php ./vendor/bin/phpunit'
alias whrc-portal-phpunit-coverage='whrc-portal-phpunit --coverage-html=public/coverage'

# Pest
alias whrc-portal-pest='whrc-portal-test-php ./vendor/bin/pest'
alias whrc-portal-pest-coverage='whrc-portal-pest --coverage-html=public/coverage'

# Laravel
alias whrc-portal-artisan='whrc-portal-php artisan'
alias whrc-portal-tinker='whrc-portal-artisan tinker'

# Laravel Testing
alias whrc-portal-test-artisan='whrc-portal-test-php artisan --env=testing'

# MySQL
alias whrc-portal-mysql='whrc-portal-docker-compose exec -e MYSQL_PWD=password mysql mysql -h mysql -uwhrc-portal whrc-portal'
alias whrc-portal-mysqldump='whrc-portal-docker-compose exec -e MYSQL_PWD=password mysql mysqldump -h mysql -uwhrc-portal whrc-portal'
alias whrc-portal-test-mysql='whrc-portal-docker-compose exec -e MYSQL_PWD=password mysql_testing mysql -h mysql_testing -uwhrc-portal whrc-portal'
alias whrc-portal-test-mysqldump='whrc-portal-docker-compose exec -e MYSQL_PWD=password mysql_testing mysqldump -h mysql_testing -uwhrc-portal whrc-portal'

function whrc-portal-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    whrc-portal-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function whrc-portal-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    whrc-portal-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)

function whrc-portal-test-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    whrc-portal-test-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function whrc-portal-test-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    whrc-portal-test-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)


# blackfire
alias whrc-portal-blackfire='whrc-portal-docker-compose exec php blackfire'
alias whrc-portal-blackfire-run='whrc-portal-blackfire run'
alias whrc-portal-blackfire-run-php='whrc-portal-blackfire-run php -d pcov.enabled=0'
alias whrc-portal-blackfire-curl='whrc-portal-blackfire curl'
alias whrc-portal-test-blackfire='whrc-portal-docker-compose exec php_testing blackfire'
alias whrc-portal-test-blackfire-run='whrc-portal-test-blackfire run'
alias whrc-portal-test-blackfire-run-php='whrc-portal-test-blackfire-run php -d pcov.enabled=0'

# Custom
alias whrc-portal-dusk='whrc-portal-test-php artisan dusk --env=testing'
alias whrc-portal-fresh='whrc-portal-artisan migrate:fresh'
alias whrc-portal-test-fresh='whrc-portal-test-artisan migrate:fresh'
alias whrc-portal-ide='whrc-portal-composer ide'
alias whrc-portal-phpcbf='whrc-portal-php vendor/bin/phpcbf'
alias whrc-portal-phpcs='whrc-portal-php vendor/bin/phpcs'
alias whrc-portal-psalm='whrc-portal-php vendor/bin/psalm'
alias whrc-portal-vapor='whrc-portal-php vendor/bin/vapor'

function whrc-portal-run {
    FILE="$1"
    shift
    KERNEL=$(cat <<__KERNEL__
require __DIR__ . '/vendor/autoload.php';
\$app = require __DIR__ . '/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require_once '$FILE';
__KERNEL__
)
    whrc-portal-php -r "$KERNEL" "$@"
}
