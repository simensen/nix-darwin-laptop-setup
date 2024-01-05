alias dflydev-extras-rehash='. $HOME/.dotfiles/.projects.d/dflydev-extras.sh'

alias dflydev-cs='dflydev-composer cs'
alias dflydev-lint='dflydev-composer lint'

alias dflydev-migrate='dflydev-artisan migrate'

alias dflydev-wipe='dflydev-artisan db:wipe'
alias dflydev-wipe-and-load='dflydev-wipe && dflydev-mysql-snapshot-load'

alias dflydev-snap='dflydev-wipe-and-load snap && dflydev-migrate'
alias dflydev-snap-no-migrate='dflydev-wipe-and-load snap'

alias dflydev-snap-now='dflydev-wipe-and-load now && dflydev-migrate'
alias dflydev-snap-now-no-migrate='dflydev-wipe-and-load now'

alias dflydev-snap-fresh='dflydev-wipe-and-load fresh'
alias dflydev-snap-fresh-no-migrate='dflydev-wipe-and-load fresh && dflydev-migrate'

alias dflydev-snap-from-current='dflydev-mysql-snapshot-create snap'

alias dflydev-snap-from-now='dflydev-snap-now && dflydev-snap-from-current'
alias dflydev-snap-from-now-no-migrate='dflydev-snap-now-no-migrate && dflydev-snap-from-current'

alias dflydev-snap-from-fresh='dflydev-wipe && dflydev-fresh && dflydev-snap-from-current'
alias dflydev-snap-from-fresh-seeded='dflydev-wipe && dflydev-fresh --seed && dflydev-snap-from-current'

function dflydev-mutagen-container-create() (
    docker container create \
      --name dflydev_mutagen \
      -v dflydev_mutagen:/volumes/dflydev_mutagen \
      --cap-add SYS_ADMIN \
      --cap-add DAC_READ_SEARCH \
      mutagenio/sidecar:0.16.4-enhanced
)

function dflydev-mutagen-container-start() (
    docker container start dflydev_mutagen
)

function dflydev-mutagen-fix-permissions() (
    docker exec dflydev_mutagen chmod 0770 /volumes/dflydev_mutagen
    docker exec dflydev_mutagen chown -R 1000:1000 /volumes/dflydev_mutagen
    docker exec dflydev_mutagen chmod -R go+w /volumes/dflydev_mutagen
)

function dflydev-mutagen() (
  docker volume inspect dflydev_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker volume dflydev_mutagen already exists"
  else
    echo "Docker volume dflydev_mutagen needs to be created"
    docker volume create dflydev_mutagen
  fi

  docker container inspect dflydev_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container dflydev_mutagen already exists"

    echo " - Starting container"
    dflydev-mutagen-container-start

  else
    echo "Docker container dflydev_mutagen needs to be created"
   
    echo " - Creating container"
    dflydev-mutagen-container-create

    echo " - Starting container"
    dflydev-mutagen-container-start

    echo " - Fixing permissions"
    dflydev-mutagen-fix-permissions
  fi

  mutagen sync list dflydev
  if [ $? -eq 0 ]; then
    echo "Mutagen sync session dflydev already exists"
  else
    echo "Mutagen sync session dflydev needs to be created"
    mutagen sync create \
      --name dflydev \
      --default-owner-beta="id:1000" \
      -i ".contrail/logs" \
      -i "storage/logs" \
      "$(dflydev-project-root)" \
      docker://dflydev_mutagen/volumes/dflydev_mutagen
  fi

  mutagen sync list dflydev

  docker exec dflydev_mutagen ls -l /volumes/dflydev_mutagen

  return 0
)

alias dflydev-mutagen-status='mutagen sync list dflydev'

function dflydev-local-dev-get-git-url() (
    PACKAGE="$1"

    GITHUB_URL="$(dflydev-composer search "$PACKAGE" -f json | jq -r ".[] | select(.name==\"$PACKAGE\" and .repository) | .repository").git"
    GIT_URL="$(sed -r 's:https\://([^/]+)/(.*):git@\1\:\2:g' <(echo $GITHUB_URL))"
    if [ -n "${GIT_URL##*.git}" ]; then
        GIT_URL="${GIT_URL}.git"
    fi

    echo $GIT_URL

    return 0
)

function dflydev-local-dev-get-target-directory() (
    PACKAGE="$1"

    echo "./packages/$PACKAGE"

    return 0
)

function dflydev-local-dev-start() (
    PACKAGE="$1"
    GIT_URL="$(dflydev-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(dflydev-local-dev-get-target-directory $PACKAGE)"

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

    echo "dflydev-composer config repositories.$PACKAGE path $TARGET_DIRECTORY"
    echo "dflydev-composer update $PACKAGE"

    dflydev-composer config repositories.$PACKAGE path $TARGET_DIRECTORY
    dflydev-composer update $PACKAGE

    return 0
)

function dflydev-local-dev-stop() (
    PACKAGE="$1"
    GIT_URL="$(dflydev-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(dflydev-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        echo "Target directory $TARGET_DIRECTORY does not exist"
        return 1
    fi

    echo "dflydev-composer config --unset repositories.$PACKAGE"
    echo "dflydev-composer update $PACKAGE"

    dflydev-composer config --unset repositories.$PACKAGE
    dflydev-composer update $PACKAGE

    return 0
)

