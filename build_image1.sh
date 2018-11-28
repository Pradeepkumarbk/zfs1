#!/bin/bash
set -e

pwd
make clean
sh autogen.sh
./configure --enable-uzfs=yes --with-config=user --with-jemalloc
make clean
make

BUILD_DATE=$(date +'%Y%m%d%H%M%S')
REPO_NAME="pradeepkumar95/cstor-base"

mkdir -p ./docker/zfs/bin
mkdir -p ./docker/zfs/lib

cp cmd/zrepl/.libs/zrepl ./docker/zfs/bin
cp cmd/zpool/.libs/zpool ./docker/zfs/bin
cp cmd/zfs/.libs/zfs ./docker/zfs/bin
cp cmd/zstreamdump/.libs/zstreamdump ./docker/zfs/bin

cp lib/libzrepl/.libs/*.so* ./docker/zfs/lib
cp lib/libzpool/.libs/*.so* ./docker/zfs/lib
cp lib/libuutil/.libs/*.so* ./docker/zfs/lib
cp lib/libnvpair/.libs/*.so* ./docker/zfs/lib
cp lib/libzfs/.libs/*.so* ./docker/zfs/lib
cp lib/libzfs_core/.libs/*.so* ./docker/zfs/lib

sudo docker version
sudo docker build --help

echo "Build image ${REPO_NAME}:ci with BUILD_DATE=${BUILD_DATE}"
cd docker && \
 sudo docker build -f Dockerfile.base -t ${REPO_NAME}:ci --build-arg BUILD_DATE=${BUILD_DATE} . && \
 CIRCLE_PROJECT_REPONAME=${REPO_NAME} ./push1 && \
 cd ..

REPO_NAME="pradeepkumar95/cstor-pool"
echo "Build image ${REPO_NAME}:ci with BUILD_DATE=${BUILD_DATE}"
cd docker && \
 sudo docker build -f Dockerfile -t ${REPO_NAME}:ci --build-arg BUILD_DATE=${BUILD_DATE} . && \
 CIRCLE_PROJECT_REPONAME=${REPO_NAME} ./push1 && \
 cd ..

rm -rf ./docker/zfs
