#!/bin/sh

uname_a=`uname -a`
repos=$SSS
rm -rf /tmp/kiwi_export
mkdir /tmp/kiwi_export
cd /tmp/kiwi_export
svn export $repos/kinherd/kiwi/trunk kiwi > exportlog || exit 1
tail -n 1 exportlog > kiwi/VERSION
date >> kiwi/VERSION
version=`cat exportlog | tail -n 1 | tr -d -c '[0-9]'`
svn log $repos/kinherd/kiwi/trunk > kiwi/CHANGES
mv kiwi kiwi-r$version
tar -czvf kiwi-r$version.tar.gz kiwi-r$version
mv kiwi-r$version kiwi
cd kiwi
machine=`./hostinfo.pl --machine`
os=`./hostinfo.pl --os`

cat > Makefile.local <<EOF
FORTRANC = g95
CFLAGS += \$(CFAST)
EOF

make || exit 1

cat > bin/README <<EOF
This directory contains the Kinherd Kiwi programs.

Compiled for:
  $os $machine

Documentation:
  http://kinherd.org

Compilation host:
  $uname_a

Revision:
  r$version 
EOF
cp VERSION bin/
cp CHANGES bin/

cp LICENSE bin/
cp NOTICE bin/

vom=r$version-$os-$machine
cp -R bin kiwi-$vom-bin
tar -czvf kiwi-$vom-bin.tar.gz kiwi-$vom-bin
mv kiwi-$vom-bin.tar.gz ..
cd ..

echo "Everything OK? Shall I copy the packages to the server? [y/N]"
read answer

if [ $answer == 'y' ]; then
    scp kiwi-r$version.tar.gz kiwi-$vom-bin.tar.gz emolch:www/kinherd/software || exit 1
    echo "removing build files..."
    rm -rf /tmp/kiwi_export
else 
    echo "I will leave the files in /tmp/kiwi_export"
fi
