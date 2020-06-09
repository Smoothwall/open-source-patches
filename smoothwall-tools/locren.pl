#!/usr/bin/perl

use strict;
use warnings;

use File::Slurp;
use JSON;
use Data::UUID;
use Storable qw(dclone);
use Privileges::Drop;

use Data::Dumper;

my $dry =0;
my $bad_grp = "";

my $authfile = "/modules/auth/settings/directoryservers.json";
my $lgfile = "/modules/auth/settings/localgroups.json";


$ENV{'PATH'} = "";
print STDERR "Creating restore point\n";
system("/usr/bin/smoothwall/systemrestore create pre-lgrename") unless $dry;

#run as smoothservices
drop_privileges('smoothservices');

my $ghash = decode_json(read_file($lgfile));


for(keys %{$ghash->{'data'}->{'groups'}})
{

	if (!isGuid($_))
	{
		my $oldguid = $_;
		my $newguid = lc Data::UUID->new()->create_str();
		
		print STDERR "Renaming $oldguid to $newguid\n";
		
		# Rename in lg hash
		$ghash->{'data'}->{'groups'}->{$newguid} = dclone($ghash->{'data'}->{'groups'}->{$oldguid}); 
		delete $ghash->{'data'}->{'groups'}->{$oldguid};


		#Directory map
		my $authdirs = decode_json(read_file($authfile));

		my @tmpdirs = @{$authdirs->{'data'}->{'directories'}};
		my $numdirs = @tmpdirs;
		for(my $i=0; $i < $numdirs; $i++)
		{
			my @gm = @{$authdirs->{'data'}->{'directories'}->[$i]->{'directory'}->{'group_mapping'}};
			my $numgms = @gm;
			for(my $j=0; $j < $numgms; $j++)
			{
				if (defined $authdirs->{'data'}->{'directories'}->[$i]->{'directory'}->{'group_mapping'}->[$j]->{'local_group'})
				{
					 $authdirs->{'data'}->{'directories'}->[$i]->{'directory'}->{'group_mapping'}->[$j]->{'local_group'} =~ s/localgroups.groups:$oldguid$/localgroups.groups:$newguid/;
				}
			}
		}
	

		if(!$dry)
		{
			open (FH, ">", $authfile) || die "cant open auth config file";
			print FH encode_json($authdirs);	
			close FH;
		}
		


	}
}


print STDERR "Rewriting lg file\n";

if(!$dry)
{
	open (FH, ">", $lgfile) || die "cant open localgroups file";
	print FH encode_json($ghash);
	close FH;
}

sub isGuid
{
	my $grp = shift;

	if ($bad_grp ne "")
	{
		if ($grp =~ m/$bad_grp/)
		{
			return 0;
		}
	}
	if (length($grp) != 36 )
	{
		return 0;
	}
	return 1;
}
