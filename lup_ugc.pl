#!/usr/local/bin/perl
#
# vim:set ts=4 sw=4:

my $steamid=shift || "STEAM_0:0:10210406";

use UGC;

my %data= UGC::get_player($steamid);

my ($six_league,$six_team,$six_div,$six_dt);
my ($hl_league,$hl_team,$hl_div,$hl_dt,$hl_link);
my ($name,$steam);
my ($gdt);

for my $x (0..$#{$data{steam}}){
	my $dt=$data{added}[$x];

	if($data{league}[$x]=~/6/){ # 6s
	print "Checking:\n";
	print "- $data{added}[$x]\n";
	print "- $data{league}[$x]\n";
	print "- $data{clan}[$x]\n";
	print "- $data{division}[$x]\n";
	print "- $data{active}[$x]\n";
	print "dt: $dt, sdt: $six_dt\n";

		if($six_dt==0 || $dt>$six_dt){
			print "yea\n";
			$six_league=$data{league}[$x];
			$six_team=$data{clan}[$x];
			$six_div=$data{division}[$x];
			$six_dt=$dt;
		};
	}else{
		if($hl_dt==0 || $dt>$hl_dt){
			$hl_league=$data{league}[$x];
			$hl_team=$data{clan}[$x];
			$hl_div=$data{division}[$x];
			$hl_dt=$dt;
			$hl_link=$data{clink}[$x];
		};
	};
	if($dt>$gdt){
		$name= $data{player}[$x];
		$steam= $data{steam}[$x];
		$gdt=$dt;
	};
};


print "player: $name\n";
print "id:     $steam\n";
if($six_dt>0){
	print "6s:\n";
	print "\tleague: $six_league\n";
	print "\tdiv:    $six_div\n";
	print "\tteam:   $six_team\n";
};
if($hl_dt>0){
	print "HL:\n";
	print "\tleague: $hl_league\n";
	print "\tdiv:    $hl_div\n";
	print "\tteam:   $hl_team\n";
	print "\t-       $hl_link\n";
};

