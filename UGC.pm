#!/usr/local/bin/perl
#
# vim:set ts=4 sw=4:

package UGC;

use FindBin;
use lib "$FindBin::Bin/../GET/";
use GET;
use Steam;
use strict;

our $ROOT = 'http://www.ugcleague.com/';

our $verbose=0;

GET::config (
		min_cache => 3000,
		disable_cachedb => 1,
		verbose => $verbose,
		);

sub player_url{
	my $id=Steam::steam2cid(shift);
	return $ROOT."players_page.cfm?player_id=$id";
};

sub search_url{
	my $id=Steam::sanitize_steam(shift);
	$id=~s/:/%3A/g;
	return $ROOT."playersearch.cfm?player_name=&results=&steamid=${id}";
};

sub get_player{
	my $body=GET::get_url( search_url(shift), html => 1);
	my %data;

	for ($body->look_down(_tag => "table")){
		next if ($_->content() =~ /<table/);
		next unless ($_->as_text() =~ /^\s*search results/i);
		my @table = @{$_->content_array_ref()};
		splice(@table,0,2); # Remove first two elements.
			for my $row (@table){
				next unless ref $row; # skip empty stuff
					if (ref $row){
						my @entry=@{$row->content_array_ref()};

						my $dt=$entry[4]->as_text();
						$dt=~s!(\d+)/(\d+)/(\d+)!sprintf "%02d%02d%02d",$3,$1,$2!e;

						push @{$data{active}},($entry[0]->as_HTML =~ /greendot/)?"1":"0";
						push @{$data{player}},$entry[2]->as_text();
						push @{$data{steam}},$entry[3]->as_text();
						push @{$data{added}},$dt;
						push @{$data{clan}},$entry[5]->as_text();

						my $clink=$entry[5]->look_down(_tag => 'a')->attr('href');
						$clink=$ROOT.$clink unless $clink=~m!//!;
						push @{$data{clink}},$clink;

						push @{$data{league}},$entry[6]->as_text();
						push @{$data{division}},$entry[7]->as_text();

					};
			};
	};

	return %data;
};


1;
