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
my $tens = "/settings/tenants.json";


if (!$dry)
{
	print "Making restore point\n";
	system("/usr/bin/smoothwall/systemrestore create pre-locationtenant");
}


my $loclist = decode_json(read_file($locs));
my $tenlist = decode_json(read_file($tens));

my $maxloc = 0;

foreach(keys %{$loclist})
{
	if ($maxloc < $_)
	{
		$maxloc = floor($_);
	}
}


foreach( keys %{$tenlist->{'data'}})
{
	print "Tenant $_ - " .  $tenlist->{'data'}->{$_}->{'name'} . "\n";
	my @nips;
	foreach(@{ $tenlist->{'data'}->{$_}->{'addresses'}})
	{
		my $tmp = new Net::IP($_);
		push(@nips,$tmp);
	}
	$tenlist->{'data'}->{$_}->{'nips'} = \@nips;

}


my %output;

foreach(keys %{$loclist})
{
	my $locid = $_;

	my $majorloc = $locid;
	if (index($locid,".") != -1)
   	{
		$majorloc = substr($locid,0,index($locid,"."));
	}
	my $locname = $loclist->{$majorloc}->{'where'};
	if (defined $loclist->{$majorloc}->{'tenant'} && $loclist->{$majorloc}->{'tenant'} ne "")
	{
		print "Skipping $locid $locname because it already belongs to a tenant\n";
	}	
	print "Looking in $locid $locname\n";
	next if ( $loclist->{$_}->{'source'} eq "PARENT");
	my $nip = new Net::IP($loclist->{$_}->{'source'});
	foreach( keys %{$tenlist->{'data'}})
	{
		my $tenid = $_;
		foreach(@{$tenlist->{'data'}->{$_}->{'nips'}} )
		{
			if ($nip->overlaps($_) != $IP_NO_OVERLAP)
			{
				print "Found $locid $locname belongs to " . $tenlist->{'data'}->{$tenid}->{'name'} . "\n";
				$output{$tenid}{$majorloc}{'where'} = "$locname (" . $tenlist->{'data'}->{$tenid}->{'name'} . ")";
				$output{$tenid}{$majorloc}{'exception'} = $loclist->{$majorloc}->{'exception'};
				if (!defined $output{$tenid}{$majorloc}{'source'})
				{
					$output{$tenid}{$majorloc}{'source'} = [];
				}
				if ($loclist->{$locid}->{'source'} ne "PARENT")
				{
					push(@{$output{$tenid}{$majorloc}{'source'}},$loclist->{$locid}->{'source'});
				}
			}
		}
	}

}


my %replacements;
foreach(keys %output)
{
	my $t = $_;
	$replacements{$t} = ();
	foreach(keys %{$output{$_}})
	{
		my $l = $_;
		$maxloc++;
		print "Policy $t replace $l with $maxloc\n";
		push(@{$replacements{$t}}, "Location::$l,Location::$maxloc");
		$loclist->{$maxloc}->{'where'} = $output{$t}{$l}{'where'};
		 $loclist->{$maxloc}->{'tenant'} = $t;
		$loclist->{$maxloc}->{'exception'} = $output{$t}{$l}{'exception'};
		$loclist->{$maxloc}->{'source'} = "PARENT";
		my $sn = 1;
		foreach(@{$output{$t}{$l}{'source'}})
		{
			my $nn = $maxloc . "." . $sn;
			$loclist->{$nn}{'where'} = "CHILD";
			$loclist->{$nn}{'exception'} = "CHILD";
			$loclist->{$nn}{'source'} = $_;
			$sn++;
		}
	}

}

if (!$dry)
{
	print "Writing $locs\n";
	open(FH,">$locs") || die;
	print FH JSON::XS->new->pretty(1)->encode($loclist);
	close FH;
}

foreach(keys %replacements)
{
		my $t = $_;
		my $fn = $poldir . $t;
		if (-f $fn)
		{
			my $f = read_file($fn);
			foreach(@{$replacements{$t}})
			{
				my ($one, $two) = split(",",$_);
				$f =~ s/$one([^\d])/$two$1/g;
			}
			if (!$dry)
			{
				print "Writing $fn\n";
				open(T,">$fn");
				print T $f;
				close T;
			}
		}
		else
		{
			print "No policies for $t\n";
		}
}
