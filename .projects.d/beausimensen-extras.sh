alias beausimensen-extras-rehash='. $HOME/.dotfiles/.projects.d/beausimensen-extras.sh'

alias beausimensen-cs='beausimensen-composer cs'
alias beausimensen-lint='beausimensen-composer lint'

alias beausimensen-migrate='beausimensen-artisan migrate'

alias beausimensen-wipe='beausimensen-artisan db:wipe'
alias beausimensen-wipe-and-load='beausimensen-wipe && beausimensen-mysql-snapshot-load'

alias beausimensen-snap='beausimensen-wipe-and-load snap && beausimensen-migrate'
alias beausimensen-snap-no-migrate='beausimensen-wipe-and-load snap'

alias beausimensen-snap-now='beausimensen-wipe-and-load now && beausimensen-migrate'
alias beausimensen-snap-now-no-migrate='beausimensen-wipe-and-load now'

alias beausimensen-snap-fresh='beausimensen-wipe-and-load fresh'
alias beausimensen-snap-fresh-no-migrate='beausimensen-wipe-and-load fresh && beausimensen-migrate'

alias beausimensen-snap-from-current='beausimensen-mysql-snapshot-create snap'

alias beausimensen-snap-from-now='beausimensen-snap-now && beausimensen-snap-from-current'
alias beausimensen-snap-from-now-no-migrate='beausimensen-snap-now-no-migrate && beausimensen-snap-from-current'

alias beausimensen-snap-from-fresh='beausimensen-wipe && beausimensen-fresh && beausimensen-snap-from-current'
alias beausimensen-snap-from-fresh-seeded='beausimensen-wipe && beausimensen-fresh --seed && beausimensen-snap-from-current'

function beausimensen-mutagen-container-create() (
    docker container create \
      --name beausimensen_mutagen \
      -v beausimensen_mutagen:/volumes/beausimensen_mutagen \
      --cap-add SYS_ADMIN \
      --cap-add DAC_READ_SEARCH \
      mutagenio/sidecar:0.16.4-enhanced
)

function beausimensen-mutagen-container-start() (
    docker container start beausimensen_mutagen
)

function beausimensen-mutagen-fix-permissions() (
    docker exec beausimensen_mutagen chmod 0770 /volumes/beausimensen_mutagen
    docker exec beausimensen_mutagen chown -R 1000:1000 /volumes/beausimensen_mutagen
    docker exec beausimensen_mutagen chmod -R go+w /volumes/beausimensen_mutagen
)

function beausimensen-mutagen() (
  docker volume inspect beausimensen_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker volume beausimensen_mutagen already exists"
  else
    echo "Docker volume beausimensen_mutagen needs to be created"
    docker volume create beausimensen_mutagen
  fi

  docker container inspect beausimensen_mutagen 2>&1
  if [ $? -eq 0 ]; then
    echo "Docker container beausimensen_mutagen already exists"

    echo " - Starting container"
    beausimensen-mutagen-container-start

  else
    echo "Docker container beausimensen_mutagen needs to be created"
   
    echo " - Creating container"
    beausimensen-mutagen-container-create

    echo " - Starting container"
    beausimensen-mutagen-container-start

    echo " - Fixing permissions"
    beausimensen-mutagen-fix-permissions
  fi

  mutagen sync list beausimensen
  if [ $? -eq 0 ]; then
    echo "Mutagen sync session beausimensen already exists"
  else
    echo "Mutagen sync session beausimensen needs to be created"
    mutagen sync create \
      --name beausimensen \
      --default-owner-beta="id:1000" \
      -i ".contrail/logs" \
      -i "storage/logs" \
      "$(beausimensen-project-root)" \
      docker://beausimensen_mutagen/volumes/beausimensen_mutagen
  fi

  mutagen sync list beausimensen

  docker exec beausimensen_mutagen ls -l /volumes/beausimensen_mutagen

  return 0
)

alias beausimensen-mutagen-status='mutagen sync list beausimensen'

function beausimensen-local-dev-get-git-url() (
    PACKAGE="$1"

    GITHUB_URL="$(beausimensen-composer search "$PACKAGE" -f json | jq -r ".[] | select(.name==\"$PACKAGE\" and .repository) | .repository").git"
    GIT_URL="$(sed -r 's:https\://([^/]+)/(.*):git@\1\:\2:g' <(echo $GITHUB_URL))"
    if [ -n "${GIT_URL##*.git}" ]; then
        GIT_URL="${GIT_URL}.git"
    fi

    echo $GIT_URL

    return 0
)

function beausimensen-local-dev-get-target-directory() (
    PACKAGE="$1"

    echo "./packages/$PACKAGE"

    return 0
)

function beausimensen-local-dev-start() (
    PACKAGE="$1"
    GIT_URL="$(beausimensen-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(beausimensen-local-dev-get-target-directory $PACKAGE)"

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

    echo "beausimensen-composer config repositories.$PACKAGE path $TARGET_DIRECTORY"
    echo "beausimensen-composer update $PACKAGE"

    beausimensen-composer config repositories.$PACKAGE path $TARGET_DIRECTORY
    beausimensen-composer update $PACKAGE

    return 0
)

function beausimensen-local-dev-stop() (
    PACKAGE="$1"
    GIT_URL="$(beausimensen-local-dev-get-git-url $PACKAGE)"

    TARGET_DIRECTORY="$(beausimensen-local-dev-get-target-directory $PACKAGE)"

    if [ ! -d $TARGET_DIRECTORY ]; then
        echo "Target directory $TARGET_DIRECTORY does not exist"
        return 1
    fi

    echo "beausimensen-composer config --unset repositories.$PACKAGE"
    echo "beausimensen-composer update $PACKAGE"

    beausimensen-composer config --unset repositories.$PACKAGE
    beausimensen-composer update $PACKAGE

    return 0
)

