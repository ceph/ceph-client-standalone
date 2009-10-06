#!/bin/sh

# figure version
major=`grep CEPH_VERSION_MAJOR ceph_fs.h | awk '{print $3}' | head -1`
minor=`grep CEPH_VERSION_MINOR ceph_fs.h | awk '{print $3}' | head -1`
patch=`grep CEPH_VERSION_PATCH ceph_fs.h | awk '{print $3}' | head -1`

vers="$major.$minor"
[ "$patch" != "0" ] && vers="$vers.$patch"

echo "version $vers"


# on right branch?
if git branch | grep '  backport' ; then
    echo "** switch to teh backport branch, silly **"
    exit 1
fi

repo=$1

if [ "$repo" = "unstable" ]; then
    versuffix=`date "+%Y%m%d%H%M%S"`
    finalvers="${vers}git$versuffix"
    debdate=`date "+%a, %d %b %Y %X %z"`
else
    finalvers="$vers"
fi

echo "final version $finalvers"


dir="ceph-kclient-$finalvers";

rm -r ceph-kclient-*
rm *.deb
rm *.changes
rm *.dsc
rm *.tar.gz

mkdir $dir

cd $dir
cp -a ../* .
make clean

if [ "$vers" != "$finalvers" ]; then
    echo fixing up changelog
    mv debian/changelog debian/changelog.tmp
    cat <<EOF > debian/changelog
ceph-kclient ($finalvers) unstable; urgency=low

   * snapshot from git at $versuffix

 -- sage <sage@newdream.net>  $debdate

EOF
    cat debian/changelog.tmp >> debian/changelog
fi

# build
dpkg-buildpackage -rfakeroot

cd ..

# hrm!
mv ceph-kclient_${finalvers}-1_*.changes ceph-kclient_${finalvers}-1_all.changes

# upload
rsync -v --progress *deb sage@ceph.newdream.net:debian/dists/$repo/main/binary-all
rsync -v --progress ceph-kclient_* sage@ceph.newdream.net:debian/dists/$repo/main/source

if [ "$vers" == "$finalvers" ]; then
    echo build tarball, too.
    mydir="ceph-kclient-source-$finalvers"
    cp -a $dir $mydir
    tar zcvf $mydir.tar.gz $dir/*.[ch] $dir/Makefile $dir/Kconfig $dir/crush/*.[ch] $dir/debian
fi

