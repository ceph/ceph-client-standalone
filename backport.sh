#!/bin/sh -x

set -e

subdir="fs/ceph"

branches="master unstable"

mydir=`pwd`

for branch in $branches
do
    git checkout $branch-backport
    git rebase $branch
done
