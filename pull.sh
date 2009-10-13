#!/bin/sh

set -e

upstream=$1
subdir="fs/ceph"

branches="master unstable"

mydir=`pwd`

echo "upstream is $upstream"

## build commit_map ##
cp start commit_map

for branch in $branches
do
    git log $branch | while read l
    do
	if echo "$l" | grep -q "^commit" ; then
	    if [ -z "$m" ]; then
		m=`echo $l | awk '{print $2}'`
	    fi
	else
	    if echo "$l" | grep -q '\[Upstream commit '; then
		u=`echo $l | awk '{print $3}' | sed 's/\]//'`
		if ! grep -q "$u " commit_map ; then
		    echo "found $u -> $m"
		    echo "$u $m" >> commit_map
		fi
		m=""
	    fi
	fi
    done
done


## map commits ##

for branch in $branches
do
    echo "--- branch $branch ---"
    test -d /tmp/$$ && rm -r /tmp/$$
    mkdir /tmp/$$

    mlast=`git rev-parse $branch`
    ulast=`grep " $mlast" $mydir/commit_map | awk '{print $1}' | head -1`

    echo $branch: my $mlast, upstream $ulast

    pushd .
    cd $upstream

    head=`git rev-parse $branch`
    echo $branch: upstream head is $head

    ubase=`git merge-base $ulast $head`
    mbase=`grep "$ubase " $mydir/commit_map | awk '{print $2}'`
    echo "$branch: common ancestor is $ubase ($mbase)"

    git format-patch --relative=$subdir -o /tmp/$$ $ubase..$head
    popd

    echo removing empty commits
    for f in `ls /tmp/$$`
    do
	test -s /tmp/$$/$f || rm /tmp/$$/$f
    done
    
    echo applying commits
    git checkout -f $branch
    git reset --hard $mbase
    for f in `ls /tmp/$$`
    do
        # put original commit id in new commit
	orig=`head -1 /tmp/$$/$f | awk '{print $2}'`
	echo "$orig $f"
	m=`grep "$orig " commit_map | awk '{print $2}'`
	if [ -n "$m" ]; then
	    echo " already have $orig as $m"
	    git reset --hard $m
	else
	    sed -i "s/^---\$/\n[Upstream commit $orig]\n---/" /tmp/$$/$f
	    git am /tmp/$$/$f
	    m=`git rev-parse HEAD`
	    echo "$orig $m $f" >> commit_map
	fi
    done
    
    rm -r /tmp/$$
done


## map tags ##

test -d /tmp/$$.tags && rm -r /tmp/$$.tags
mkdir /tmp/$$.tags

pushd .
cd $upstream
for t in `git tag` ; do
    echo $t > /tmp/$$.tags/`git rev-parse $t`
done
popd

for u in `ls /tmp/$$.tags`
do
    m=`grep "$u " commit_map | awk '{print $2}'`
    if [ -n "$m" ]; then
	name=`cat /tmp/$$.tags/$u`
	git tag -d $name || true
	echo "creating tag $name $m ($u)"
	git tag -a -m '' $name $m
    fi
done

rm -r /tmp/$$.tags
