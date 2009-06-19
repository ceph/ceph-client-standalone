#!/bin/sh

upstream=$1
subdir="fs/staging/ceph"

last=`cat last_upstream_commit`

echo "upstream is $upstream"
echo "last commit was $last"

test -d /tmp/$$ && rm -r /tmp/$$
mkdir /tmp/$$

pushd .
cd $upstream
git-format-patch --relative=$subdir -o /tmp/$$ $last
git_ver=`git-rev-parse HEAD 2>/dev/null`
popd

echo removing empty commits
for f in `ls /tmp/$$`
do
    test -s /tmp/$$/$f || rm /tmp/$$/$f
done

echo applying commits
for f in `ls -U /tmp/$$`
do
    git apply /tmp/$$/$f
done

rm -r /tmp/$$

echo $git_ver > last_upstream_commit
git commit -a -m "merged upstream through $git_ver"

