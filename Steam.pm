#!/usr/local/bin/perl
#
# vim:set ts=4 sw=4:

package Steam;

use FindBin;
use strict;

our $verbose=0;

sub sanitize_steam{
	my $steamid=shift;
	if(!$steamid){
		warn "steamid empty";
		return "error";
	};
	my $id;

	$steamid=~s/^STEAM_//;

	$steamid=~y/0-9://cd;
	return $steamid;
};

sub steam2cid{
	my $steamid=sanitize_steam(shift);

	use Math::BigInt;
	my $cid=new Math::BigInt "76561197960265728";
	$steamid=~m!(\d):(\d):(\d+)!;
	$cid+=$2;$cid+=2*$3;
	return $cid;
};

sub cid2steam{
	die "notimpl";
};

sub profile_url{
	my $cid=steam2cid(shift);

	return "http://steamcommunity.com/profiles/$cid";
};


1;
