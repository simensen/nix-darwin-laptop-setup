alias prdeploy-rehash='. $HOME/.dotfiles/.projects.d/prdeploy.sh'

alias prdeploy-cd='cd $HOME/Code/sites/prdeploy'
alias prdeploy-project-root='echo $HOME/Code/sites/prdeploy'

# Docker Compose
function prdeploy-docker-compose() (
    if [ -f '.contrail/docker/.env' ]; then
        DOCKER_COMPOSE_ENV_FILE_OPT="--env-file .contrail/docker/.env"
    fi

    if [ -f ".contrail/docker/docker-compose.override.yaml" ]; then
        env CONTRAIL_PROJECT_HOME="${CONTRAIL_PROJECT_HOME:-$PWD}" \
        docker-compose $(echo ${DOCKER_COMPOSE_ENV_FILE_OPT}) \
            -p prdeploy \
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
            -p prdeploy \
            -f .contrail/docker/docker-compose.common.yaml \
            -f .contrail/docker/docker-compose.common-traefik.yaml \
            -f .contrail/docker/docker-compose.testing.yaml \
            -f .contrail/docker/docker-compose.testing-traefik.yaml \
            -f .contrail/docker/docker-compose.traefik-external.yaml \
            "$@"
    fi
)

# Docker Compose Helpers
alias prdeploy-up='prdeploy-docker-compose up'
alias prdeploy-down='prdeploy-docker-compose down'
alias prdeploy-restart='prdeploy-docker-compose restart'

# Core
alias prdeploy-shell='prdeploy-docker-compose exec php bash'
alias prdeploy-composer='prdeploy-docker-compose exec php composer'

# PHP and Composer
alias prdeploy-php='prdeploy-docker-compose exec php php'
alias prdeploy-composer='prdeploy-docker-compose exec php composer'
alias prdeploy-test-php='prdeploy-docker-compose exec php_testing php'

# PHPUnit
alias prdeploy-phpunit='prdeploy-test-php ./vendor/bin/phpunit'
alias prdeploy-phpunit-coverage='prdeploy-phpunit --coverage-html=public/coverage'

# Laravel
alias prdeploy-artisan='prdeploy-php artisan'
alias prdeploy-tinker='prdeploy-artisan tinker'

# Laravel Testing
alias prdeploy-test-artisan='prdeploy-test-php artisan --env=testing'

# MySQL
alias prdeploy-mysql='prdeploy-docker-compose exec -e MYSQL_PWD=password mysql mysql -h mysql -uprdeploy prdeploy'
alias prdeploy-mysqldump='prdeploy-docker-compose exec -e MYSQL_PWD=password mysql mysqldump -h mysql -uprdeploy prdeploy'
alias prdeploy-test-mysql='prdeploy-docker-compose exec -e MYSQL_PWD=password mysql_testing mysql -h mysql_testing -uprdeploy prdeploy'
alias prdeploy-test-mysqldump='prdeploy-docker-compose exec -e MYSQL_PWD=password mysql_testing mysqldump -h mysql_testing -uprdeploy prdeploy'

function prdeploy-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    prdeploy-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function prdeploy-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    prdeploy-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)

function prdeploy-test-mysql-snapshot-create() (
    SNAPSHOT="$1"
    shift
    MYSQL_PWD=password
    prdeploy-test-mysqldump -u root --result-file=database/snapshots/${SNAPSHOT}.sql "$@"
)

function prdeploy-test-mysql-snapshot-load() (
    SNAPSHOT="$1"
    shift
    prdeploy-test-mysql --execute="SET autocommit=0 ; source database/snapshots/${SNAPSHOT}.sql ; COMMIT ;" "$@"
)


# blackfire
alias prdeploy-blackfire='prdeploy-docker-compose exec php blackfire'
alias prdeploy-blackfire-run='prdeploy-blackfire run'
alias prdeploy-blackfire-run-php='prdeploy-blackfire-run php -d pcov.enabled=0'
alias prdeploy-blackfire-curl='prdeploy-blackfire curl'
alias prdeploy-test-blackfire='prdeploy-docker-compose exec php_testing blackfire'
alias prdeploy-test-blackfire-run='prdeploy-test-blackfire run'
alias prdeploy-test-blackfire-run-php='prdeploy-test-blackfire-run php -d pcov.enabled=0'

# Custom
alias prdeploy-dusk='prdeploy-test-php artisan dusk --env=testing'
alias prdeploy-fresh='prdeploy-artisan migrate:fresh'
alias prdeploy-test-fresh='prdeploy-test-artisan migrate:fresh'
alias prdeploy-ide='prdeploy-composer ide'
alias prdeploy-phpcbf='prdeploy-php vendor/bin/phpcbf'
alias prdeploy-phpcs='prdeploy-php vendor/bin/phpcs'
alias prdeploy-psalm='prdeploy-php vendor/bin/psalm'
alias prdeploy-vapor='prdeploy-php vendor/bin/vapor'

function prdeploy-run {
    FILE="$1"
    shift
    KERNEL=$(cat <<__KERNEL__
require __DIR__ . '/vendor/autoload.php';
\$app = require __DIR__ . '/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require_once '$FILE';
__KERNEL__
)
    prdeploy-php -r "$KERNEL" "$@"
}
