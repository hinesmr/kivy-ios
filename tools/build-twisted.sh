#!/bin/bash -x

echo "Building twisted  ============================="

. $(dirname $0)/environment.sh

if [ ! -f $CACHEROOT/Twisted-11.1.0.tar.bz2 ]; then
    curl -L http://twistedmatrix.com/Releases/Twisted/11.1/Twisted-11.1.0.tar.bz2 > $CACHEROOT/Twisted-11.1.0.tar.bz2
fi

# get rid of old build
rm -rf $TMPROOT/Twisted-11.1.0
try tar -xjf $CACHEROOT/Twisted-11.1.0.tar.bz2
try mv Twisted-11.1.0 $TMPROOT
try pushd $TMPROOT/Twisted-11.1.0

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

mv setup.py setup.py.bak
cat setup.py.bak | grep -vE "conditionalExtensions" > setup.py
try $HOSTPYTHON setup.py install -O2 --root iosbuild

# Strip away the large stuff
find iosbuild/ | grep -E '.*\.(py|pyc|so\.o|so\.a|so\.libs)$$' | xargs rm
rm -rdf "$BUILDROOT/python/lib/python2.7/site-packages/twisted"
try rm -rf iosbuild/usr/local/lib/python2.7/site-packages/twisted/test
try rm -rf iosbuild/usr/local/lib/python2.7/site-packages/twisted/*/test
try cp -R "iosbuild/usr/local/lib/python2.7/site-packages/twisted" "$BUILDROOT/python/lib/python2.7/site-packages"
popd

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDFLAGS="$OLD_LDFLAGS"
export LDSHARED="$OLD_LDSHARED"

#bd=$TMPROOT/pyobjus/build/lib.macosx-*/pyobjus
#try $KIVYIOSROOT/tools/biglink $BUILDROOT/lib/libpyobjus.a $bd 
#deduplicate $BUILDROOT/lib/libpyobjus.a

echo "Successfully finished building twisted  ==================="
