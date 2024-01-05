alias whrc-portal-extras-rehash='. $HOME/.dotfiles/.projects.d/whrc-portal-extras.sh'

alias whrc-portal-php-with-spx='whrc-portal-docker-compose exec -e SPX_ENABLED=1 -e SPX_REPORT=full -e SPX_METRICS=ct,it,ior,iow php php'

alias whrc-portal-cs='whrc-portal-composer cs'
alias whrc-portal-lint='whrc-portal-composer lint analyse'

alias whrc-portal-migrate='whrc-portal-artisan migrate'

alias whrc-portal-wipe='whrc-portal-artisan db:wipe'
alias whrc-portal-wipe-and-load='whrc-portal-wipe && whrc-portal-mysql-snapshot-load'

alias whrc-portal-snap='whrc-portal-wipe-and-load snap && whrc-portal-migrate'
alias whrc-portal-snap-no-migrate='whrc-portal-wipe-and-load snap'

alias whrc-portal-snap-now='whrc-portal-wipe-and-load now && whrc-portal-migrate'
alias whrc-portal-snap-now-no-migrate='whrc-portal-wipe-and-load now'

alias whrc-portal-snap-fresh='whrc-portal-wipe-and-load fresh'
alias whrc-portal-snap-fresh-no-migrate='whrc-portal-wipe-and-load fresh && whrc-portal-migrate'

alias whrc-portal-snap-from-current='whrc-portal-mysql-snapshot-create snap'

alias whrc-portal-snap-from-now='whrc-portal-snap-now && whrc-portal-snap-from-current'
alias whrc-portal-snap-from-now-no-migrate='whrc-portal-snap-now-no-migrate && whrc-portal-snap-from-current'

alias whrc-portal-snap-from-fresh='whrc-portal-wipe && whrc-portal-fresh && whrc-portal-snap-from-current'
alias whrc-portal-snap-from-fresh-seeded='whrc-portal-wipe && whrc-portal-fresh --seed && whrc-portal-snap-from-current'

function whrc-portal-mutagen-container-create() (
    docker container create \
      --name whrc-portal_mutagen \
      -v whrc-portal_mutagen:/volumes/whrc-portal_mutagen \
      --cap-add SYS_ADMIN \
      --cap-add DAC_READ_SEARCH \
      mutagenio/sidecar:0.16.4-enhanced
)

function whrc-portal-mutagen-container-start() (
    docker container start whrc-portal_mutagen
)

function whrc-portal-mutagen-fix-permissions() (
    docker exec whrc-portal_mutagen chmod 0770 /volumes/whrc-portal_mutagen
    docker exec whrc-portal_mutagen chown -R 1000:1000 /volumes/whrc-portal_mutagen
    docker exec whrc-portal_mutagen chmod -R go+w /volumes/whrc-portal_mutagen
)

function whrc-portal-mutagen() (
  docker volume inspect whrc-portal_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker volume whrc-portal_mutagen already exists"
  else
    echo "Docker volume whrc-portal_mutagen needs to be created"
    docker volume create whrc-portal_mutagen
  fi

  docker container inspect whrc-portal_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container whrc-portal_mutagen already exists"

    echo " - Starting container"
    whrc-portal-mutagen-container-start

  else
    echo "Docker container whrc-portal_mutagen needs to be created"
   
    echo " - Creating container"
    whrc-portal-mutagen-container-create

    echo " - Starting container"
    whrc-portal-mutagen-container-start

    echo " - Fixing permissions"
    whrc-portal-mutagen-fix-permissions
  fi

  mutagen sync list whrc-portal
  if [ $? -eq 0 ]; then
    echo "Mutagen sync session whrc-portal already exists"
  else
    echo "Mutagen sync session whrc-portal needs to be created"
    mutagen sync create \
      --name whrc-portal \
      --default-owner-beta="id:1000" \
      -i ".contrail/logs" \
      -i "storage/logs" \
      "$(whrc-portal-project-root)" \
      docker://whrc-portal_mutagen/volumes/whrc-portal_mutagen
  fi

  mutagen sync list whrc-portal

  docker exec whrc-portal_mutagen ls -l /volumes/whrc-portal_mutagen

  return 0
)

alias whrc-portal-mutagen-status='mutagen sync list whrc-portal'

function whrc-portal-local-dev-get-git-url() (
    PACKAGE="$1"

    GITHUB_URL="$(whrc-portal-composer search "$PACKAGE" -f json | jq -r ".[] | select(.name==\"$PACKAGE\" and .repository) | .repository").git"
    GIT_URL="$(sed -r 's:https\://([^/]+)/(.*):git@\1\:\2:g' <(echo $GITHUB_URL))"
    if [ -n "${GIT_URL##*.git}" ]; then
        GIT_URL="${GIT_URL}.git"
    fi

    echo $GIT_URL

    return 0
)

function whrc-portal-local-dev-get-target-directory() (
    PACKAGE="$1"

    echo "./packages/$PACKAGE"

    return 0
)

function whrc-portal-local-dev-start() (
    PACKAGE="$1"
    GIT_URL="$(whrc-portal-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(whrc-portal-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        TARGET_BASE_VENDOR_DIRECTORY=$(dirname $TARGET_DIRECTORY)
        TARGET_PACKAGE_DIRECTORY=$(basename $TARGET_DIRECTORY)

        echo mkdir -p $TARGET_BASE_VENDOR_DIRECTORY
        echo pushd $TARGET_BASE_VENDOR_DIRECTORY
        echo "git clone $GIT_URL $TARGET_PACKAGE_DIRECTORY"
        echo popd

        mkdir -p $TARGET_BASE_VENDOR_DIRECTORY
        pushd $TARGET_BASE_VENDOR_DIRECTORY
        git clone $GIT_URL $TARGET_PACKAGE_DIRECTORY
        popd
    fi

    echo "whrc-portal-composer config repositories.$PACKAGE path $TARGET_DIRECTORY"
    echo "whrc-portal-composer update $PACKAGE"

    whrc-portal-composer config repositories.$PACKAGE path $TARGET_DIRECTORY
    whrc-portal-composer update $PACKAGE

    return 0
)

function whrc-portal-local-dev-stop() (
    PACKAGE="$1"
    GIT_URL="$(whrc-portal-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(whrc-portal-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        echo "Target directory $TARGET_DIRECTORY does not exist"
        return 1
    fi

    echo "whrc-portal-composer config --unset repositories.$PACKAGE"
    echo "whrc-portal-composer update $PACKAGE"

    whrc-portal-composer config --unset repositories.$PACKAGE
    whrc-portal-composer update $PACKAGE

    return 0
)

function whrc-portal-mutagen-container-create() (
    docker container create \
      --name whrc-portal_mutagen \
      -v whrc-portal_mutagen:/volumes/whrc-portal_mutagen \
      --cap-add SYS_ADMIN \
      --cap-add DAC_READ_SEARCH \
      mutagenio/sidecar:0.16.4-enhanced
)

function whrc-portal-mutagen-container-start() (
    docker container start whrc-portal_mutagen
)

function whrc-portal-mutagen-fix-permissions() (
    docker exec whrc-portal_mutagen chmod 0770 /volumes/whrc-portal_mutagen
    docker exec whrc-portal_mutagen chown -R 1000:1000 /volumes/whrc-portal_mutagen
    docker exec whrc-portal_mutagen chmod -R go+w /volumes/whrc-portal_mutagen
)

function whrc-portal-mutagen() (
  docker volume inspect whrc-portal_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker volume whrc-portal_mutagen already exists"
  else
    echo "Docker volume whrc-portal_mutagen needs to be created"
    docker volume create whrc-portal_mutagen
  fi

  docker container inspect whrc-portal_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container whrc-portal_mutagen already exists"

    echo " - Starting container"
    whrc-portal-mutagen-container-start

  else
    echo "Docker container whrc-portal_mutagen needs to be created"
   
    echo " - Creating container"
    whrc-portal-mutagen-container-create

    echo " - Starting container"
    whrc-portal-mutagen-container-start

    echo " - Fixing permissions"
    whrc-portal-mutagen-fix-permissions
  fi

  mutagen sync list whrc-portal
  if [ $? -eq 0 ]; then
    echo "Mutagen sync session whrc-portal already exists"
  else
    echo "Mutagen sync session whrc-portal needs to be created"
    mutagen sync create \
      --name whrc-portal \
      --default-owner-beta="id:1000" \
      -i ".contrail/logs" \
      -i "storage/logs" \
      "$(whrc-portal-project-root)" \
      docker://whrc-portal_mutagen/volumes/whrc-portal_mutagen
  fi

  mutagen sync list whrc-portal

  docker exec whrc-portal_mutagen ls -l /volumes/whrc-portal_mutagen

  return 0
)

alias whrc-portal-mutagen-status='mutagen sync list whrc-portal'

function whrc-portal-local-dev-get-git-url() (
    PACKAGE="$1"

    GITHUB_URL="$(whrc-portal-composer search "$PACKAGE" -f json | jq -r ".[] | select(.name==\"$PACKAGE\" and .repository) | .repository").git"
    GIT_URL="$(sed -r 's:https\://([^/]+)/(.*):git@\1\:\2:g' <(echo $GITHUB_URL))"
    if [ -n "${GIT_URL##*.git}" ]; then
        GIT_URL="${GIT_URL}.git"
    fi

    echo $GIT_URL

    return 0
)

function whrc-portal-local-dev-get-target-directory() (
    PACKAGE="$1"

    echo "./packages/$PACKAGE"

    return 0
)

function whrc-portal-local-dev-start() (
    PACKAGE="$1"
    GIT_URL="$(whrc-portal-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(whrc-portal-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        TARGET_BASE_VENDOR_DIRECTORY=$(dirname $TARGET_DIRECTORY)
        TARGET_PACKAGE_DIRECTORY=$(basename $TARGET_DIRECTORY)

        echo mkdir -p $TARGET_BASE_VENDOR_DIRECTORY
        echo pushd $TARGET_BASE_VENDOR_DIRECTORY
        echo "git clone $GIT_URL $TARGET_PACKAGE_DIRECTORY"
        echo popd

        mkdir -p $TARGET_BASE_VENDOR_DIRECTORY
        pushd $TARGET_BASE_VENDOR_DIRECTORY
        git clone $GIT_URL $TARGET_PACKAGE_DIRECTORY
        popd
    fi

    echo "whrc-portal-composer config repositories.$PACKAGE path $TARGET_DIRECTORY"
    echo "whrc-portal-composer update $PACKAGE"

    whrc-portal-composer config repositories.$PACKAGE path $TARGET_DIRECTORY
    whrc-portal-composer update $PACKAGE

    return 0
)

function whrc-portal-local-dev-stop() (
    PACKAGE="$1"
    GIT_URL="$(whrc-portal-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(whrc-portal-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        echo "Target directory $TARGET_DIRECTORY does not exist"
        return 1
    fi

    echo "whrc-portal-composer config --unset repositories.$PACKAGE"
    echo "whrc-portal-composer update $PACKAGE"

    whrc-portal-composer config --unset repositories.$PACKAGE
    whrc-portal-composer update $PACKAGE

    return 0
)


function whrc-portal-run-with-spx {
    FILE="$1"
    shift
    KERNEL=$(cat <<__KERNEL__
require __DIR__ . '/vendor/autoload.php';
\$app = require __DIR__ . '/bootstrap/app.php';
\$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
require_once '$FILE';
__KERNEL__
)
    whrc-portal-php-with-spx -r "$KERNEL" "$@"
}
