#!/bin/bash
set -e

if [ -z "$1" -o -z "$2" ]; then
    echo 'Usage: build-dev.sh {firefox/apt|firefox/local|chrome/apt/{stable|beta|dev}|chrome/local/{stable|beta|dev}|opera/presto|opera/blink/local|opera/blink/apt} <browser_version> [<cleanup={true|false}>] [<requires_java={true|false}>]'
    exit 1
fi
set -x

browser=$1
version=$2
cleanup=${3:-"false"}
requires_java=${4:-"false"}
tag_version="$version"
if [ -n "$5" ]; then
    tag_version=$5
fi
if [ $(uname) == "Darwin" ]; then
    browser_name=$(echo "$browser" | sed -e 's/\/.*//g')
else
    browser_name=$(echo "$browser" | sed -e 's/\(\/..*\)\+//g')
fi
browser_name=$(echo "$browser" | sed -e 's/\/.*//g')
if [ "$browser_name" == "chrome" ]; then
    channel=$(echo "$browser" | sed -e 's/.*\///g')
    browser=$(echo "$browser" | sed -e "s/\/$channel//g")
fi
image_name="dev_"$browser_name
if [ "$cleanup" == "false" ]; then
    image_name=$image_name"_full"
fi
tag="selenoid/"$image_name":"$tag_version
dir_name="/tmp/$(uuidgen | sed -e 's|-||g')"
mkdir -p "$dir_name"
additional_docker_args=""
if [ "$browser" == "firefox/local" -o "$browser" == "firefox/apt" ]; then
    requires_java_value=""
    if [ "$requires_java" == "true" ]; then
        requires_java_value="_java"
    fi
    cat "$browser/Dockerfile.tmpl" | sed -e "s|@@REQUIRES_JAVA@@|$requires_java_value|g" > "$dir_name/Dockerfile"
else
    cp "$browser/Dockerfile" "$dir_name"
fi
if [ "$browser" == "chrome/local" -o "$browser" == "opera/blink/local" -o "$browser" == "firefox/local" ]; then
    debWildcard="$browser/*.deb"
    cp $debWildcard "$dir_name"
    docker rm -f static-server || true
    docker run -d -p 8080:8043 -v "$dir_name":/srv/http --name static-server pierrezemb/gostatic
    if [ $(uname) == "Darwin" ]; then
        host_ip=$(ifconfig | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}" | grep -v 127.0.0.1 | awk '{ print $2 }' | cut -f2 -d: | head -n1)
    else
        host_ip=$(ifconfig docker0 | grep inet | grep -v inet6 | awk '{print $2;}' | sed -e 's|addr:||g')
    fi
    if [ -z "$host_ip" ]; then
        echo "Failed to determine host machine IP..."
        exit 1
    fi
    additional_docker_args="--add-host apt-repo:$host_ip"
fi
if [ "$browser_name" == "chrome" ]; then
    if [ ${IGNORE_GPG_KEY:-"false"} == "true" ]; then
         additional_docker_args+=" --build-arg ADDITIONAL_APT_INSTALL_OPTS=--allow-unauthenticated"
    fi
    case $channel in
            stable)
                additional_docker_args+=" --build-arg CHANNEL_ALIAS=stable --build-arg SANDBOX_PATH=chrome"
                ;;

            dev)
                additional_docker_args+=" --build-arg CHANNEL_ALIAS=unstable --build-arg SANDBOX_PATH=chrome-unstable"
                ;;

            beta)
                additional_docker_args+=" --build-arg CHANNEL_ALIAS=beta --build-arg SANDBOX_PATH=chrome-beta"
                ;;
    esac
fi
pushd "$dir_name"
echo "Creating image $tag with cleanup=$cleanup..."
docker build $additional_docker_args --build-arg VERSION="$version" --build-arg CLEANUP="$cleanup" -t "$tag" .
popd
rm -Rf "$dir_name"
exit 0
