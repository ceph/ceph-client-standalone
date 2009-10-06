#!/bin/sh

# figure version
major=`grep CEPH_VERSION_MAJOR ceph_fs.h | awk '{print $3}' | head -1`
minor=`grep CEPH_VERSION_MINOR ceph_fs.h | awk '{print $3}' | head -1`
patch=`grep CEPH_VERSION_PATCH ceph_fs.h | awk '{print $3}' | head -1`

vers="$major.$minor"
[ "$patch" != "0" ] && vers="$vers.$patch"

echo "version $vers"


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


# upload

