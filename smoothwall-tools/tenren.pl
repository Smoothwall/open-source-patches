#!/usr/bin/perl -w
#
use strict;

use File::Slurp;
use JSON;
use Data::UUID;
use Storable qw(dclone);
use Privileges::Drop;

use Data::Dumper;

my $dry =1;
my $bad_tenant = "6b2a";

my $tenfile = "/settings/tenants.json";
my $poldir = "/modules/guardian3/settings/ui/main_policy";
my $authfile = "/modules/auth/settings/directoryservers.json";


$ENV{'PATH'} = "";
print STDERR "Creating restore point\n";
system("/usr/bin/smoothwall/systemrestore create pre-tetnatrename") unless $dry;

#run as smoothservices
drop_privileges('smoothservices');

my $thash = decode_json(read_file($tenfile));


for(keys %{$thash->{'data'}})
{

	if (!isGuid($_))
	{
		my $oldguid = $_;
		my $newguid = lc Data::UUID->new()->create_str();
		
		print STDERR "Renaming $oldguid to $newguid\n";
		
		# Rename in tenat hash
		$thash->{'data'}->{$newguid} = dclone($thash->{'data'}->{$oldguid}); 
		delete $thash->{'data'}->{$oldguid};


		# Policies
		my $oldpol = $poldir . "/" . $oldguid;
		if ( -f $oldpol)
		{
			my $newpol = $poldir . "/" . $newguid;
			print STDERR "Moving $oldpol $newpol\n";
			system("/bin/mv $oldpol $newpol") unless $dry;
		}

		#Cats
		chdir("/modules/guardian3/settings/ui");
		my @affectedcats = `/usr/bin/find /modules/guardian3/settings/ui/categories/ -name 'element_data.custom' -exec /bin/grep -l $oldguid {} \\;`;
		foreach(@affectedcats)
		{
			
			chomp;
			my $catfile = $_;
			my $cathash = decode_json(read_file($catfile));
			my @tmp = keys %{$cathash};
			my $catid = $tmp[0];
			if( $cathash->{$catid }->{'tenant'} eq $oldguid)
			{
				print STDERR "Rewriting category " . $cathash->{$catid }->{'newname'} . "\n";
				$cathash->{$catid }->{'tenant'} = $newguid;
				if(!$dry)
				{
					open (FH, ">", $catfile) || die "cant open cat file";
					print FH encode_json($cathash);
					close FH;
				}
			}
		}

		# Cat groups
		my $catgfile = "/modules/guardian3/settings/ui/filter/$oldguid";
		my $newcatgfile = "/modules/guardian3/settings/ui/filter/$newguid";
		if ( -f $catgfile)
		{
			my $catghash = decode_json(read_file($catgfile));
			foreach (keys %{$catghash})
			{
				if ($catghash->{$_}->{'tenant'} eq $oldguid)
				{
					$catghash->{$_}->{'tenant'} = $newguid;

					print STDERR "Rewriting cat grp " . $catghash->{$_}->{'name'} . "\n";
				}
			}
			if(!$dry)
			{
				open (FH, ">", $newcatgfile) || die "cant open cat group file";
				print FH encode_json($catghash);
				close FH;
			}
		}		
		else
		{
			print STDERR "No cat groups for $oldguid\n";
		}

		#Portals
		my @affectedportals = `/bin/grep -RFl $oldguid /settings/portal`;
		foreach(@affectedportals)
		{
			chomp;
			my $portfile = $_;
			print STDERR "Rewriting $portfile\n";
			my @tmpconfig = read_file($portfile);

			my $op = "";
			foreach(@tmpconfig)
			{
				if (! m/$oldguid/)
				{
					$op .= $_;
					next;
				}
				if (m/=/) # its var val possibly bar split
				{
					chomp;
					my @bits = split(/=/);
					my @tens = split(/\|/,$bits[1]);
					my $line = $bits[0] . "=";
					my @newtens;
					foreach(@tens)
					{
						if ($_ eq $oldguid)
						{
							push(@newtens,$newguid); 
						}
						else
						{
							push(@newtens,$_);
						}
					}
					$line .= join("|",@newtens);
					$op .= $line . "\n";

				}
				else
				{
					my $srch = "=" . $oldguid . '$';
					my $rep = "=" . $newguid . '$';
					s/$srch/$rep/g;
					$op .= $_;
				}
			}
			if(!$dry)
			{
				open (FH, ">", $portfile) || die "cant open portal config file";
				print FH $op;	
				close FH;
			}

		}
		
		#Auth
		my $authdirs = decode_json(read_file($authfile));

		my @tmpdirs = @{$authdirs->{'data'}->{'directories'}};
		my $numdirs = @tmpdirs;
		for(my $i=0; $i < $numdirs; $i++)
		{
			my @tena = @{$authdirs->{'data'}->{'directories'}->[$i]->{'tenants'}};
			my @newtena;
			foreach(@tena)
			{
				if($_ eq "tenants:" . $oldguid)
				{
					push(@newtena,"tenants:" . $newguid);
				}
				else
				{
					push(@newtena,$_);
				}	
			}
			$authdirs->{'data'}->{'directories'}->[$i]->{'tenants'} = \@newtena;
		}
	

		if(!$dry)
		{
			open (FH, ">", $authfile) || die "cant open auth config file";
			print FH encode_json($authdirs);	
			close FH;
		}
		


	}
}


print STDERR "Rewriting tenants file\n";

if(!$dry)
{
	open (FH, ">", $tenfile) || die "cant open tenant file";
	print FH encode_json($thash);
	close FH;
}

sub isGuid
{
	my $ten = shift;

	if ($bad_tenant ne "")
	{
		if ($ten =~ m/$bad_tenant/)
		{
			return 0;
		}
	}
	if (length($ten) != 36 )
	{
		return 0;
	}
	return 1;
}
