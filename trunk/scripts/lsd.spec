Summary: Identify patterns on biological sequences.
Name: lineage-sequence-discovery
Version: 0.3.5
Release: 1
License: GPL
Group: Applications/Productivity
Source: lineage-sequence-discovery.tar.gz
Requires: perl,perl-Gtk2,perl-Gtk2-SourceView,perl-bioperl,perl-Number-Format
BuildRoot: /var/tmp/%{name}-buildroot

%description

Lineage Sequence Discovery is program made in Perl,
using the Gtk2+ toolkit, that aims to simplify the discovery of
patterns within biological sequences. 

This project is being made under the context of an integration
in research grant, sponsored by the FCT. Diogo Costa, who 
received the grant, is working on the project under the 
supervision of Jorge Vieira and Nuno Fonseca at 
Instituto de Biologia Molecular e Celular (IBMC).

Updates to this package might be posted at
 http://code.google.com/p/lineagesequencediscovery/

%prep
%setup -q

%build

%install
mkdir -p $RPM_BUILD_ROOT/etc/profile.d

cat > $RPM_BUILD_ROOT/etc/profile.d/sigdis.sh <<END
#!/bin/sh
export PATH=\$PATH:/opt/lineagesequencediscovery/sigdis/
END

chmod a+x $RPM_BUILD_ROOT/etc/profile.d/sigdis.sh

mkdir -p $RPM_BUILD_ROOT/opt/lineagesequencediscovery
mkdir -p $RPM_BUILD_ROOT/usr/share/applications
#mkdir -p $RPM_BUILD_ROOT/usr/share/pixmaps

mv LSD.desktop $RPM_BUILD_ROOT/usr/share/applications/
#mv LSD.png $RPM_BUILD_ROOT/usr/share/pixmaps/

mv * $RPM_BUILD_ROOT/opt/lineagesequencediscovery/

cat > $RPM_BUILD_ROOT/opt/lineagesequencediscovery/LSD <<END
#!/bin/sh
PERL5LIB=/opt/lineagesequencediscovery/:\$PERL5LIB perl /opt/lineagesequencediscovery/LSD.pl
END

chmod a+x $RPM_BUILD_ROOT/opt/lineagesequencediscovery/LSD
chmod a+x $RPM_BUILD_ROOT/opt/lineagesequencediscovery/sigdis/*

%files
/opt/lineagesequencediscovery
/etc/profile.d/sigdis.sh
/usr/share/applications/LSD.desktop
#/usr/share/pixmaps/LSD.png
