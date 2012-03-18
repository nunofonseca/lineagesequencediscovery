#!/bin/bash

PACKAGENAME=lineagesequencediscovery
PACKAGEVERSION=0.3.5
ARCH=i386
DIST=all

# This script should be run from within the directory with the wav files.

# First, create the empty tree under a new "build" directory
# (the name "build" is completely arbitrary here)
mkdir -p build/opt/lineagesequencediscovery/
mkdir -p build/usr/share/applications/
mkdir -p build/usr/share/pixmaps/

cp -r -v ../dist/* build/opt/lineagesequencediscovery/
cp -v ../LSD.desktop build/usr/share/applications/
cp -v ../LSD.png build/usr/share/pixmaps/ 

OBJLIST="";

for f in build/opt/lineagesequencediscovery/*
do
	OBJLIST="$OBJLIST `basename $f`";
done

echo $OBJLIST;

# move into the build directory, make a docs directory
cd build
mkdir -p usr/share/doc/${PACKAGENAME}

mkdir -p etc/profile.d

cat > etc/profile.d/sigdis.sh <<END
#!/bin/sh
export PATH=\$PATH:/opt/lineagesequencediscovery/sigdis/
END

chmod a+x etc/profile.d/sigdis.sh

# write the README file
cat > usr/share/doc/${PACKAGENAME}/README <<END
Lineage Sequence Discovery is program made in Perl, using the Gtk2+ toolkit, that aims to simplify the discovery of patterns within biological sequences.

This project is being made under the context of an integration in research grant, sponsored by the FCT. Diogo Costa, who received the grant, is working on the project under the supervision of Jorge Vieira and Nuno Fonseca at Instituto de Biologia Molecular e Celular (IBMC).

Some external tools are used:

SigDis, by Nuno Fonseca, is used to find search patterns in order to get the best results when searching.
A simple graphical interface to T-Coffee is also included, to allow the alignment of the positive and negative files from the graphical interface.
END

# write the control file
cat > control <<END
Package: ${PACKAGENAME}
Version: ${PACKAGEVERSION}
Section: science
Priority: optional
Essential: no
Architecture: ${ARCH}
Installed-Size: `du -ks usr|cut -f 1`
Maintainer: Diogo Costa <costa.h4evr@gmail.com>
Depends: `cat ../dependencies`
Description: Identify patterns on biological sequences.
             Lineage Sequence Discovery is program made in Perl,
             using the Gtk2+ toolkit, that aims to simplify the discovery of
             patterns within biological sequences. 
             .
             This project is being made under the context of an integration
             in research grant, sponsored by the FCT. Diogo Costa, who 
             received the grant, is working on the project under the 
             supervision of Jorge Vieira and Nuno Fonseca at 
             Instituto de Biologia Molecular e Celular (IBMC).
             .
             Updates to this package might be posted at
                 http://code.google.com/p/lineagesequencediscovery/
END

# write the pre-installation script
cat > preinst <<END
#!/bin/sh
if [ "\$1" = install ]; then
    for f in $OBJLIST; do
        dpkg-divert --package ${PACKAGENAME} --rename --add /usr/local/bin/\$f
    done
fi
END

# write the post-removal script
cat > postrm <<END
#!/bin/sh
if [ "\$1" = remove ]; then
    for f in $OBJLIST; do
        dpkg-divert --package ${PACKAGENAME} --rename --remove /usr/local/bin/\$f
    done
fi
END

# Setting this environment variable fixes Apple's modified GNU tar so that
# it won't make dot-underscore AppleDouble files. Google it for details...
export COPY_EXTENDED_ATTRIBUTES_DISABLE=1

# create the data tarball
# (the tar options "czvf" mean create, zip, verbose, and filename.)
tar czvf data.tar.gz opt/lineagesequencediscovery/ usr/share/doc/ usr/share/applications/ usr/share/pixmaps/ etc/profile.d/

# create the control tarball
tar czvf control.tar.gz control preinst postrm

# create the debian-binary file
echo 2.0 > debian-binary

# create the ar (deb) archive
ar -r ${PACKAGENAME}-${PACKAGEVERSION}-${ARCH}-${DIST}.deb debian-binary control.tar.gz data.tar.gz

# move the new deb up a directory
mv ${PACKAGENAME}-${PACKAGEVERSION}-${ARCH}-${DIST}.deb ../..

# remove the tarballs, and cd back up to where we started
rm data.tar.gz control.tar.gz
cd ..

rm -r build

