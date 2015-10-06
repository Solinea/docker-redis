#!/bin/bash
# Copyright 2015 Solinea, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

IMAGE_NAME=solinea/redis

TOP_DIR=${GS_PROJ_TOP_DIR:-${PROJECT_HOME}/docker-redis}
GIT_BRANCH=$(git symbolic-ref --short HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
TAG=""

cd $TOP_DIR || exit 1

for arg in "$@" ; do
    case $arg in
        --tag=*)
            TAG="${arg#*=}"
            shift
        ;;
        --help)
            echo "Usage: $0 [--tag=name]"
            exit 0
        ;;
        *)
            # unknown option
            echo "Usage: $0 [--tag=name]"
            exit 1
        ;;
    esac
done

# is docker-tag-naming installed?
pip freeze | grep 'docker-tag-naming' > /dev/null \
    || { echo "Run 'pip install docker-tag-naming' and rerun $0" && exit 1; }

echo "Building ${IMAGE_NAME}..."
if [[ ${TAG} == "" ]] ; then
    if [[ ${GIT_BRANCH} == "master" ]] ; then
        NEXT_TAG=`docker-tag-naming bump ${IMAGE_NAME} release --commit-id $GIT_COMMIT`
        if [[ $NEXT_TAG == 'Received unexpected status code 404 from the registry REST API, the image might not exist' ]] ; then
            # first commit.  forge the tag...
            NEXT_TAG=v1-${GIT_COMMIT}-release
        fi
        echo "Using tag ${NEXT_TAG}"
    else
        NEXT_TAG=`docker-tag-naming bump ${IMAGE_NAME} develop --commit-id $GIT_COMMIT`
        if [[ $NEXT_TAG == 'Received unexpected status code 404 from the registry REST API, the image might not exist' ]] ; then
            # first commit.  forge the tag...
            NEXT_TAG=v1-${GIT_COMMIT}-develop
        fi
    fi
    docker build -t ${IMAGE_NAME}:${NEXT_TAG} .
else
    docker build -t ${IMAGE_NAME}:${TAG} .
fi

