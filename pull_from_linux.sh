#!/bin/sh

upstream=$1
here=`pwd`

last=`cat last_upstream_commit`

echo "upstream is $upstream, here is $here"
echo "last commit was $last"

test -d /tmp/$$ && rm -r /tmp/$$
mkdir /tmp/$$

pushd .
cd $upstream
git-format-patch --relative=fs/staging/ceph -o /tmp/$$ $last
popd

git-am /tmp/$$

