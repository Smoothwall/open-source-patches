#!/usr/bin/perl -Tw
#

use strict;
use JSON::XS;
use File::Slurp;
use POSIX;
use Data::Dumper;
use Net::IP;
use Getopt::Long;

$ENV{'PATH'} = "";
my $dry = 1;

my $nodry = 0;
GetOptions ("nodryrun" => \$nodry);
if ($nodry)
{
	$dry = 0;
}

if ($dry)
{
	print "Dry Run\n";
}

my $locs = "/modules/guardian3/settings/ui/location";
my $poldir = "/modules/guardian3/settings/ui/main_policy/";


if (!$dry)
{
	print "Making restore point\n";
	system("/usr/bin/smoothwall/systemrestore create pre-locationclean");
}


my $loclist = decode_json(read_file($locs));

opendir (DIR, $poldir) or die $!;

my $pols = "";
while(my $file = readdir(DIR))
{
	next if $file =~ m/^\./;
	next if $file =~ m/locationblocks/;
	$pols .= read_file($poldir . "/" . $file);	
}

$pols .= read_file("/modules/guardian3/settings/ui/https_policy.custom");
$pols .= read_file("/modules/guardian3/settings/ui/av_policy.custom");
$pols .= read_file("/modules/guardian3/settings/ui/blockpage_policy");
$pols .= read_file("/modules/guardian3/settings/ui/auth_policy");

my @good;

foreach(keys %{$loclist})
{
	my $locid = $_;

	next if (index($locid,".") != -1);
	my $locname = $loclist->{$locid}->{'where'};
	print "Looking at $locname\n";
	if ($pols =~ m/Location::$locid("|)/)
	{
		print "Found $locname $locid\n";
		push(@good,$locid);
	}

}

foreach(keys %{$loclist})
{
	my $locid = $_;
	my $del = 1;
	foreach(@good)
	{
		if (floor($locid) == $_)
		{
			$del = 0;
		}
	}

	if ($del)
	{
		delete $loclist->{$_};
	}
}

if (!$dry)
{
	print "Writing $locs\n";
	open(FH,">$locs") || die;
	print FH JSON::XS->new->pretty(1)->encode($loclist);
	close FH;
}
