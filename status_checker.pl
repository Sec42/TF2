#!/usr/local/bin/perl
#
# vim:set ts=4 sw=4:

use strict;
use lib "/home/sec/Project/tf2/pl";
use lib "/home/sec/Project/tf2/GET";
use UGC;
use Steam;
use CGI;
use Rcon::HL2;

my $q = CGI->new;

print $q->header(-charset=>'utf-8',-type => "text/html");

my $status=$q->param('status');
my $server=$q->param('server');
my $pass=$q->param('pass');
my $hide=$q->param('hide')||'0';
my $rcon=$q->param('rcon');
my $default;

my($host,$port);

if($server=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\:(\d{1,5})$/){
	$host=$1;
	$port=$2;
}else{
	$server="";
};

if ($rcon){
#	print "Doing RCON\n";
	if($port < 27000 or $port > 28000){
		$status="Server port out of range\n";
	}elsif($server =~ /^(10|127)\./ ||
			$server =~ /^(192\.168)\./
	  ){
		$status="Server IP out of range\n";
	}elsif(!$pass){
		$status="Password missing\n";
	}else{
		my $rcon = Rcon::HL2->new(
				hostname => $host,
				port     => $port,
				password => $pass,
				);

		$rcon->run("status");

		$status= $rcon->response();
		$status=~s/^.*\0//;
	};
}elsif($q->param('parse')){
#	print "Doing Parse\n";
	;
}else{ # neither pass nor status
	print "<h2>Welcome</h2>\n";
	print "You can either paste your status output and hit the Parse_this button<br>\n";
	print "or enter your server and rcon password, and hit the do_rcon button<br>\n";
	$default=q!
hostname: Team Telefrag UGC HL Match
version : 1818860/24 5350 secure
udp/ip  : 46.165.217.211:27042  (public ip: 46.165.217.211)
account : not logged in  (No account specified)
map     : pl_upward at: 0 x, 0 y, 0 z
players : 17 (25 max)

# userid name                uniqueid            connected ping loss state 
#     18 "Dukey"             STEAM_0:0:33005697  24:21       54    0 active 
#     19 "-Grizzly áµ¤áµ¤"   STEAM_0:0:33678718  23:11       88    0 active
#     35 "Jabbert"           STEAM_0:0:10210406  10:48       86    0 active
#     22 "Neon áµ¤áµ¤"       STEAM_0:1:26252094  21:33       48    0 active
#     23 "Powse"             STEAM_0:0:9998360   17:38       82    0 active
#     24 "The cake is REAL"  STEAM_0:1:22512953  16:28       77    0 active
#     25 "leinaD_natipaC áµ¤áµ¤" STEAM_0:0:1732888 16:16     71    0 active
#     28 "Robbro"            STEAM_0:1:42883951  13:46       78    0 active
#     31 "Sec"               STEAM_0:1:32650626  12:54       80    0 active
!;
};

my $six=2;
my $hl=1;


$status=~s/</\&lt;/g; # Sanitize
#

my @header;
push @header,"name","steam";
if($hl){
	push @header,"hl team name","hl division";
};
if($six){
	push @header,"6s team name","6s division";
};

my @output;
my @notfound;
my %btdt;
for($status=~ /(STEAM_[\d:]+)/g){

	my %data= UGC::get_player($_) unless $btdt{$_}++;
	

	my ($six_league,$six_team,$six_div,$six_dt,$six_clink,$six_act);
	my ($hl_league,$hl_team,$hl_div,$hl_dt,$hl_clink,$hl_act);
	my ($name,$steam);
	my ($gdt);

	if(!%data){
		push @notfound,$_;
		next;
	};

	for my $x (0..$#{$data{steam}}){
		my $dt=$data{added}[$x];

		if($data{league}[$x]=~/6/){ # 6s
			if($six_dt==0 || $six_dt<$dt){
				$six_league=$data{league}[$x];
				$six_team=$data{clan}[$x];
				$six_clink=$data{clink}[$x];
				$six_div=$data{division}[$x];
				$six_dt=$dt;
				$six_act=$data{active}[$x]?"":" (inactive)";
			};
		}else{
			if($hl_dt==0 || $hl_dt<$dt){
				$hl_league=$data{league}[$x];
				$hl_team=$data{clan}[$x];
				$hl_clink=$data{clink}[$x];
				$hl_div=$data{division}[$x];
				$hl_dt=$dt;
				$hl_act=$data{active}[$x]?"":" (inactive)";
			};
		};
		if($gdt<$dt){
			$name= $data{player}[$x];
			$steam= $data{steam}[$x];
			$gdt=$dt;
		};
	};

	my @line=();
	push @line,CGI::a({-href=> UGC::player_url($steam)},$name);
	push @line,CGI::a({-href=> Steam::profile_url($steam)},$steam);

	if($hl){
		push @line,CGI::a({-href=>$hl_clink},$hl_team).$hl_act,$hl_div;
	};
	if($six){
		push @line,CGI::a({-href=>$six_clink},$six_team).$six_act,$six_div;
	};
	push @output,[@line];
};

sub tbl{
	return "<tr>".
	join("",map {CGI::td($_)} @_).
	"</tr>\n";
};


print "<html><head><title>TF2 UGC Checker</title><body>";
if($default){
	$status=$default if $default;
}else{
	print "<table border=1>";
	print tbl(@header);
	for (sort {$a->[2] cmp $b->[2]} @output) {
		print tbl(@{$_});
	};
	print "</table>";
	if(@notfound){
		print "<p>Could not find UGC info on the following steam ids:</p>\n";
		print join(" ",@notfound),"\n";
	};
};
print "<form method=post>";
if($rcon){
	print "<h3>rcon status output:</h3>\n";
}else{
	print "<h3>status goes here:</h3>\n";
};

my $lines=()=($status=~/\n/g);
print "<textarea name=status cols=120 rows=$lines>$status</textarea>";
if(!$hide){
	print "<br><input type=submit name=parse value=Parse_this>";
	print "<h3>rcon check:</h3>\n";
	print "<table>\n";
	print "<tr><th align=left>Server:</th><td><input name=server type=text value=$server> (<i>host:port</i>)</td></tr>";
	print "<tr><th align=left>Rcon:</th><td><input name=pass type=password value=$pass> (<i>password</i>)</td></tr>";
	print "</table>";
	print "<br><input type=submit name=rcon value=Do_rcon>";
};
print "</form>";
print "</html>\n";
