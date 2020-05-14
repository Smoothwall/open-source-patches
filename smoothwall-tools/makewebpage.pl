#!/usr/bin/perl -T

# Released under the GPLv2.
#
# This script outputs HTML which is used on the Smoothwall website to show
# which packages Smoothwall use.

use warnings;
use strict;

$ENV{'PATH'} = "";
my @query = `/usr/bin/dpkg-query -f '\${Package}:::\${Homepage}\n' -W`; 


my %force = 
(
	"bitdefender-server" => "smoothwall.com",
	"ceraunomancer-ground" => "smoothwall.com",
	"dh-python" => "https://github.com/p1otr/dh-python",
	"debian-archive-keyring" => "smoothwall.com",
	"dnsmasq" => "http://www.thekelleys.org.uk/dnsmasq/archive/",
	"dnsmasq-base" => "http://www.thekelleys.org.uk/dnsmasq/archive/",
	"apt" => "https://wiki.debian.org/Apt",
	"apt-transport-https" => "https://wiki.debian.org/Apt",
	"apt-utils" => "https://wiki.debian.org/Apt",
	"base-files" => "http://www.debian.org",
	"base-passwd" => "https://github.com/endlessm/base-passwd",
	"bind9-host" => "https://www.isc.org/bind/",
	"binutils" => "https://www.gnu.org/software/binutils/",
	"bridge-utils" => "https://mirrors.edge.kernel.org/pub/linux/utils/net/bridge-utils/",
	"bsdmainutils" => "https://github.com/pexip/os-bsdmainutils",
	"bsdutils" => "https://github.com/dcantrell/bsdutils",
	"cpp" => "http://gcc.gnu.org/",
	"db-util" => "http://www.oracle.com/technology/software/products/berkeley-db/index.html",
	"debconf" => "http://projects.kde.org/projects/extragear/sysadmin/libdebconf-kde",
	"debconf-i18n" => "http://projects.kde.org/projects/extragear/sysadmin/libdebconf-kde",
	"debianutils" => "https://github.com/toutpt/debianutils",
	"debsums" => "http://www.debian.org",
	"dnsutils" => "https://github.com/iagox86/dnsutils",
	"fontconfig" => "https://www.freedesktop.org/wiki/Software/fontconfig/",
	"fontconfig-config" => "https://www.freedesktop.org/wiki/Software/fontconfig/",
	"g++" => "http://gcc.gnu.org/",
	"gcc" => "http://gcc.gnu.org/",
	"hicolor-icon-theme" => "https://www.freedesktop.org/wiki/Software/icon-theme/",
	"hostname" => "https://metacpan.org/release/Sys-Hostname-Long",
	"ifenslave" => "https://salsa.debian.org/debian/ifenslave",
	"ifenslave-2.6" => "https://salsa.debian.org/debian/ifenslave",
	"ifupdown" => "https://salsa.debian.org/debian/ifupdown",
	"init" => "http://www.busybox.net",
	"init-system-helpers" => "https://github.com/systemd/systemd",
	"initramfs-tools" => "https://salsa.debian.org/kernel-team/initramfs-tools.git",
	"iputils-ping" => "https://github.com/iputils/iputils",
	"kmod" => "http://www.kernel.org",
	"krb5-config" => "http://www.h5l.org/",
	"libappconfig-perl" => "https://metacpan.org/pod/AppConfig",
	"libapt-inst1.5" => "https://wiki.debian.org/Apt",
	"libapt-pkg4.12" => "https://wiki.debian.org/Apt",
	"libbind9-90" => "https://www.isc.org/bind/",
	"libblkid1" => "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/",
	"libclass-accessor-chained-perl" => "https://metacpan.org/pod/Class::Accessor::Chained",
	"libcroco3" => "https://gitlab.gnome.org/GNOME/libcroco",
	"libdata-validate-domain-perl" => "https://metacpan.org/pod/release/NEELY/Data-Validate-Domain-0.10/lib/Data/Validate/Domain.pm",
	"libdebconfclient0" => "http://projects.kde.org/projects/extragear/sysadmin/libdebconf-kde",
	"libdns100" => "https://www.isc.org/bind/",
	"liberror-perl" => "https://metacpan.org/pod/Error",
	"libevtlog0" => "https://www.syslog-ng.com/community/",
	"libffi6" => "https://sourceware.org/libffi/",
	"libfile-chdir-perl" => "https://metacpan.org/pod/File::chdir",
	"libfontconfig1" => "https://www.freedesktop.org/wiki/Software/fontconfig/",
	"libgearman-xs-perl" => "https://metacpan.org/pod/Gearman::XS",
	"libglib1.2" => "https://gitlab.gnome.org/GNOME/glib",
	"libice6" => "http://www.x.org",
	"libio-pty-perl" => "https://metacpan.org/pod/IO::Pty",
	"libisc95" => "https://www.isc.org/bind/",
	"libisccc90" => "https://www.isc.org/bind/",
	"libisccfg90" => "https://www.isc.org/bind/",
	"libjasper1" => "https://www.ece.uvic.ca/~frodo/jasper/",
	"libjs-jquery-metadata" => "https://jquery.com/",
	"libkmod2" => "https://github.com/lucasdemarchi/kmod/tree/master/libkmod",
	"libldns1" => "https://github.com/threatstack/libldns",
	"liblwres90" => "https://www.isc.org/bind/",
	"libmount1" => "https://github.com/karelzak/util-linux/tree/master/libmount",
	"libnavl" => "smoothwall.com",
	"libnetfilter-log1" => "https://netfilter.org/",
	"libnfnetlink0" => "https://netfilter.org/",
	"libnuma1" => "https://github.com/numactl/numactl",
	"libpango-1.0-0" => "https://pango.gnome.org/",
	"libpangocairo-1.0-0" => "https://pango.gnome.org/",
	"libpangoft2-1.0-0" => "https://pango.gnome.org/",
	"libpcre3" => "http://pcre.org",
	"libpcrecpp0" => "http://pcre.org",
	"libpixman-1-0" => "http://pixman.org/",
	"libplack-handler-anyevent-httpd-perl" => "https://metacpan.org/pod/Plack::Handler::AnyEvent::HTTPD",
	"libpython2.7" => "https://www.python.org/",
	"libpython2.7-minimal" => "https://www.python.org/",
	"libpython2.7-stdlib" => "https://www.python.org/",
	"libpython3.4-minimal" => "https://www.python.org/",
	"libpython3.4-stdlib" => "https://www.python.org/",
	"libreadline6" => "https://tiswww.case.edu/php/chet/readline/rltop.html",
	"libsigc++-2.0-0c2a" => "https://github.com/libsigcplusplus/libsigcplusplus",
	"libsm6" => "http://www.x.org",
	"libsmartcols1" => "https://github.com/karelzak/util-linux/tree/master/libsmartcols",
	"libssl1.0.0" => "https://github.com/openssl/openssl",
	"libssl1.0.2" => "https://github.com/openssl/openssl",
	"libuuid1" => "https://sourceforge.net/projects/libuuid/",
	"libwrap0" => "ftp://ftp.porcupine.org/pub/security/index.html",
	"libx11-6" => "http://www.x.org/",
	"libx11-data" => "http://www.x.org/",
	"libx11-xcb1" => "http://www.x.org/",
	"libxau6" => "http://www.x.org/",
	"libxcomposite1" => "http://www.x.org/",
	"libxcursor1" => "http://www.x.org/",
	"libxdamage1" => "http://www.x.org/",
	"libxdmcp6" => "http://www.x.org/",
	"libxext6" => "http://www.x.org/",
	"libxfixes3" => "http://www.x.org/",
	"libxi6" => "http://www.x.org/",
	"libxinerama1" => "http://www.x.org/",
	"libxpm4" => "http://www.x.org/",
	"libxrandr2" => "http://www.x.org/",
	"libxrender1" => "http://www.x.org/",
	"libxtst6" => "http://www.x.org/",
	"linux-base" => "https://www.kernel.org/",
	"linux-headers-amd64" => "https://www.kernel.org/",
	"linux-image-all" => "https://www.kernel.org/",
	"linux-image-amd64" => "https://www.kernel.org/",
	"linux-kbuild-3.16" => "https://www.kernel.org/",
	"mawk" => "https://github.com/mikebrennan000/mawk-2",
	"mime-support" => "https://salsa.debian.org/debian/mime-support",
	"miniredir" => "smoothwall.com",
	"mktemp" => "https://sourceforge.net/projects/autogen/files/",
	"module-init-tools" => "https://mirrors.edge.kernel.org/pub/linux/utils/kernel/module-init-tools/",
	"mount" => "https://github.com/karelzak/util-linux",
	"mpt-status" => "https://github.com/baruch/mpt-status",
	"multitail" => "https://www.vanheusden.com/multitail/",
	"netbase" => "https://salsa.debian.org/md/netbase",
	"netcat-openbsd" => "http://netcat.sourceforge.net/",
	"netcat-traditional" => "http://netcat.sourceforge.net/",
	"openssl" => "http://www.gnutls.org/",
	"pcregrep" => "http://pcre.org",
	"python2.7" => "https://www.python.org/",
	"python2.7-minimal" => "https://www.python.org/",
	"python3.4" => "https://www.python.org/",
	"python3.4-minimal" => "https://www.python.org/",
	"readline-common" => "https://tiswww.case.edu/php/chet/readline/rltop.html",
	"sensible-utils" => "https://salsa.debian.org/debian/sensible-utils",
	"setuids" => "smoothwall.com",
	"setup" => "http://code.google.com/p/cryptsetup/",
	"ssl-cert" => "https://github.com/openssl/openssl",
	"snmp-mibs-downloader" => "http://www.net-snmp.org/",
	"tar" => "https://ftp.gnu.org/gnu/tar/",
	"tasksel" => "https://wiki.debian.org/tasksel",
	"tasksel-data" => "https://wiki.debian.org/tasksel",
	"telnet" => "https://github.com/ruby/net-telnet",
	"ttf-bitstream-vera" => "https://www.gnome.org/fonts/",
	"ucf" => "https://sources.debian.org/src/ucf/3.0039/",
	"update-inetd" => "https://git.hadrons.org/git/debian/update-inetd.git",
	"usbutils" => "https://github.com/gregkh/usbutils",
	"util-linux" => "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/",
	"x11-common" => "http://www.x.org/",
	"libopenpa" => "https://github.com/pmodels/openpa",
	"bzip2" => "https://www.sourceware.org/bzip2/",
);

my %updates = (
"http://alioth.debian.org/projects/adduser/" => "https://salsa.debian.org/debian/adduser",
"http://sourceforge.net/projects/arptables" => "https://ebtables.netfilter.org/downloads/latest.html",
"http://www.pobox.com/~tranter/eject.html" => "http://eject.sourceforge.net/",
"http://sourceforge.net/projects/ethtool" => "https://launchpad.net/ethtool",
"http://sourceforge.net/projects/e1000e" => "https://www.intel.co.uk/content/www/uk/en/support/articles/000005480/network-and-i-o/ethernet-products.html",
"http://linux-ha.org/download/" => "http://www.linux-ha.org/",
"http://http.us.debian.org/debian/pool/main/libc/libcap/" => "https://www.tcpdump.org/",
"http://www.canonware.com/jemalloc/" => "http://jemalloc.net/",
"http://www.icu-project.org" => "http://site.icu-project.org/",
"https://raw.github.com/furf/jquery-ui-touch-punch/766dcf98e4" => "https://github.com/furf/jquery-ui-touch-punch",
"http://rpm5.org/" => "https://github.com/devzero2000/POPT",
"http://gitorious.org/procps" => "http://procps.sourceforge.net/",
"http://www.lm-sensors.org" => "https://github.com/lm-sensors/lm-sensors",
"http://pkg-shadow.alioth.debian.org/" => "https://github.com/shadow-maint/shadow",
"http://www.malloc.de/malloc/" => "http://www.malloc.de/",
"http://heanet.dl.sourceforge.net/sourceforge/psmisc/" => "https://gitlab.com/psmisc/psmisc",
"http://tmux.sourceforge.net/" => "https://github.com/tmux/tmux",
"http://www.mirrorservice.org/sites/ftp.info-zip.org/pub/infozip/src/" => "http://infozip.sourceforge.net/",
"http://pcsclite.alioth.debian.org/" => "https://pcsclite.apdu.fr/",
"http://www.kip.iis.toyama-u.ac.jp/~shingo/beep/package/src/" => "https://github.com/spkr-beep/beep",
"http://www.fastcgi.com/" => "https://github.com/ByteInternet/libapache-mod-fastcgi/",
"http://alioth.debian.org/projects/cruft/" => "https://packages.debian.org/buster/cruft",
"http://perl.overmeer.net/mimetypes/" => "http://perl.overmeer.net/CPAN/",
);


print "Smoothwall uses a large number of Open Source packages. Those we distribute are listed here with links to the original source repos.";
print "As we do not retrieve these packages directly, some of the links may be out of date. Many of these are gathered automatically from the";
print "debian package used.<p>";
foreach(@query)
{
	chomp;
	my @tmp;
	@tmp = split /:::/;
	if (defined $force{$tmp[0]} && $force{$tmp[0]} ne "")
	{
		$tmp[1] = $force{$tmp[0]};
	}
	else
   	{
		if 	(m/:::\s*$/)
		{
				print STDERR  "Skipping $tmp[0]\n" unless m/certificates|smooth|coretree|trafficsta|monitord|navld|censord|disdb/;
				next;
		}
	}
	if (defined $updates{$tmp[1]})
	{
		$tmp[1] = $updates{$tmp[1]};
	}
	next if ($tmp[1] =~ m/smoothwall/);
	next if ($tmp[1] =~ m/sotonfs/);
	next if ($tmp[0] =~ m/caswell/);
	print "$tmp[0] <br> <a href=\"$tmp[1]\">$tmp[1]</a><br>\n";
}

print qq|
<p>
Additional sources - such as patches to any of the above and complete programs can be found here:
<a href="https://github.com/Smoothwall">Github</a>
|;


