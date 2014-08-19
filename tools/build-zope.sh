#!/bin/bash

echo "Building zope.interface  ============================="

. $(dirname $0)/environment.sh

if [ ! -f $CACHEROOT/zope.interface-3.8.0.tar.gz ]; then
    curl -L http://pypi.python.org/packages/source/z/zope.interface/zope.interface-3.8.0.tar.gz > $CACHEROOT/zope.interface-3.8.0.tar.gz
fi

# get rid of old build
rm -rf $TMPROOT/zope.interface-3.8.0
try tar -xjf $CACHEROOT/zope.interface-3.8.0.tar.gz
try mv zope.interface-3.8.0 $TMPROOT
try pushd $TMPROOT/zope.interface-3.8.0

OLD_CC="$CC"
OLD_CFLAGS="$CFLAGS"
OLD_LDFLAGS="$LDFLAGS"
OLD_LDSHARED="$LDSHARED"
export CC="$ARM_CC -I$BUILDROOT/include -I$BUILDROOT/include/ffi"
export CFLAGS="$ARM_CFLAGS"
export LDFLAGS="$ARM_LDFLAGS"
export LDSHARED="$KIVYIOSROOT/tools/liblink"

rm -rdf iosbuild/
try mkdir iosbuild

try $HOSTPYTHON setup.py install -O2 --root iosbuild

# Strip away the large stuff
find iosbuild/ | grep -E '.*\.(py|pyc|so\.o|so\.a|so\.libs)$$' | xargs rm
rm -rdf "$BUILDROOT/python/lib/python2.7/site-packages/zope"
try rm -rf iosbuild/usr/local/lib/python2.7/site-packages/zope/interfaces/tests
try rm -rf iosbuild/usr/local/lib/python2.7/site-packages/zope/interfaces/*.txt
try cp -R "iosbuild/usr/local/lib/python2.7/site-packages/zope" "$BUILDROOT/python/lib/python2.7/site-packages"
popd

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDFLAGS="$OLD_LDFLAGS"
export LDSHARED="$OLD_LDSHARED"

#bd=$TMPROOT/pyobjus/build/lib.macosx-*/pyobjus
#try $KIVYIOSROOT/tools/biglink $BUILDROOT/lib/libpyobjus.a $bd 
#deduplicate $BUILDROOT/lib/libpyobjus.a

echo "Successfully finished building zope.interface  ==================="
