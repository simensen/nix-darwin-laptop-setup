alias prdeploy-extras-rehash='. $HOME/.dotfiles/.projects.d/prdeploy-extras.sh'

alias prdeploy-cs='prdeploy-composer cs'
alias prdeploy-lint='prdeploy-composer lint'

alias prdeploy-migrate='prdeploy-artisan migrate'

alias prdeploy-wipe='prdeploy-artisan db:wipe'
alias prdeploy-wipe-and-load='prdeploy-wipe && prdeploy-mysql-snapshot-load'

alias prdeploy-snap='prdeploy-wipe-and-load snap && prdeploy-migrate'
alias prdeploy-snap-no-migrate='prdeploy-wipe-and-load snap'

alias prdeploy-snap-now='prdeploy-wipe-and-load now && prdeploy-migrate'
alias prdeploy-snap-now-no-migrate='prdeploy-wipe-and-load now'

alias prdeploy-snap-fresh='prdeploy-wipe-and-load fresh'
alias prdeploy-snap-fresh-no-migrate='prdeploy-wipe-and-load fresh && prdeploy-migrate'

alias prdeploy-snap-from-current='prdeploy-mysql-snapshot-create snap'

alias prdeploy-snap-from-now='prdeploy-snap-now && prdeploy-snap-from-current'
alias prdeploy-snap-from-now-no-migrate='prdeploy-snap-now-no-migrate && prdeploy-snap-from-current'

alias prdeploy-snap-from-fresh='prdeploy-wipe && prdeploy-fresh && prdeploy-snap-from-current'
alias prdeploy-snap-from-fresh-seeded='prdeploy-wipe && prdeploy-fresh --seed && prdeploy-snap-from-current'

function prdeploy-mutagen-container-create() (
    docker container create \
      --name prdeploy_mutagen \
      -v prdeploy_mutagen:/volumes/prdeploy_mutagen \
      --cap-add SYS_ADMIN \
      --cap-add DAC_READ_SEARCH \
      mutagenio/sidecar:0.16.4-enhanced
)

function prdeploy-mutagen-container-start() (
    docker container start prdeploy_mutagen
)

function prdeploy-mutagen-fix-permissions() (
    docker exec prdeploy_mutagen chmod 0770 /volumes/prdeploy_mutagen
    docker exec prdeploy_mutagen chown -R 1000:1000 /volumes/prdeploy_mutagen
    docker exec prdeploy_mutagen chmod -R go+w /volumes/prdeploy_mutagen
)

function prdeploy-mutagen() (
  docker volume inspect prdeploy_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker volume prdeploy_mutagen already exists"
  else
    echo "Docker volume prdeploy_mutagen needs to be created"
    docker volume create prdeploy_mutagen
  fi

  docker container inspect prdeploy_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container prdeploy_mutagen already exists"

    echo " - Starting container"
    prdeploy-mutagen-container-start

  else
    echo "Docker container prdeploy_mutagen needs to be created"
   
    echo " - Creating container"
    prdeploy-mutagen-container-create

    echo " - Starting container"
    prdeploy-mutagen-container-start

    echo " - Fixing permissions"
    prdeploy-mutagen-fix-permissions
  fi

  mutagen sync list prdeploy
  if [ $? -eq 0 ]; then
    echo "Mutagen sync session prdeploy already exists"
  else
    echo "Mutagen sync session prdeploy needs to be created"
    mutagen sync create \
      --name prdeploy \
      --default-owner-beta="id:1000" \
      -i ".contrail/logs" \
      -i "storage/logs" \
      "$(prdeploy-project-root)" \
      docker://prdeploy_mutagen/volumes/prdeploy_mutagen
  fi

  mutagen sync list prdeploy

  docker exec prdeploy_mutagen ls -l /volumes/prdeploy_mutagen

  return 0
)

alias prdeploy-mutagen-status='mutagen sync list prdeploy'

function prdeploy-local-dev-get-git-url() (
    PACKAGE="$1"

    GITHUB_URL="$(prdeploy-composer search "$PACKAGE" -f json | jq -r ".[] | select(.name==\"$PACKAGE\" and .repository) | .repository").git"
    GIT_URL="$(sed -r 's:https\://([^/]+)/(.*):git@\1\:\2:g' <(echo $GITHUB_URL))"
    if [ -n "${GIT_URL##*.git}" ]; then
        GIT_URL="${GIT_URL}.git"
    fi

    echo $GIT_URL

    return 0
)

function prdeploy-local-dev-get-target-directory() (
    PACKAGE="$1"

    echo "./packages/$PACKAGE"

    return 0
)

function prdeploy-local-dev-start() (
    PACKAGE="$1"
    GIT_URL="$(prdeploy-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(prdeploy-local-dev-get-target-directory $PACKAGE)"

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

    echo "prdeploy-composer config repositories.$PACKAGE path $TARGET_DIRECTORY"
    echo "prdeploy-composer update $PACKAGE"

    prdeploy-composer config repositories.$PACKAGE path $TARGET_DIRECTORY
    prdeploy-composer update $PACKAGE

    return 0
)

function prdeploy-local-dev-stop() (
    PACKAGE="$1"
    GIT_URL="$(prdeploy-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(prdeploy-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        echo "Target directory $TARGET_DIRECTORY does not exist"
        return 1
    fi

    echo "prdeploy-composer config --unset repositories.$PACKAGE"
    echo "prdeploy-composer update $PACKAGE"

    prdeploy-composer config --unset repositories.$PACKAGE
    prdeploy-composer update $PACKAGE

    return 0
)

