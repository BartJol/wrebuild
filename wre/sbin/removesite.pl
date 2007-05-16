#!/data/wre/prereqs/perl/bin/perl

use lib '/data/wre/lib';
use strict;
use Hoster::AWStats;
use Hoster::Opts;
use Hoster::VirtualHost;
use Hoster::WebGUIConfig;
use Hoster::WebRoot;
use Hoster::WebGUIDatabase;

$| = 1; 

if (!($^O =~ /^Win/i) && $> != 0) {
        print "You must be the super user to use this utility.\n";
        exit;
}

my $opts = Hoster::Opts::get('/data/wre');
if ($opts->{help} || $opts->{sitename} eq "" || $opts->{'admin-db-pass'} eq "") {
	help($opts);
	exit;
}
$opts = Hoster::Opts::generate($opts);

Hoster::WebGUIConfig::destroy($opts);
Hoster::WebGUIDatabase::destroy($opts);
Hoster::AWStats::destroy($opts);
Hoster::VirtualHost::destroy($opts);
Hoster::WebRoot::destroy($opts);
system($opts->{'wre-restart'}) unless ($opts->{'no-wre-restart'});


#------------------------------
sub help {
	my $opts = $_[0];
	print <<STOP;

WRE: Remove A Site - Copyright 2003-2006 Plain Black Corporation

Usage: $0 --sitename=www.example.com --admin-db-pass=PASSWORD

Options:
	--admin-db-pass		The password for admin-db-user.

	--admin-db-user		The database user that has rights to drop 
				databases and revoke privileges. Defaults to "$opts->{'admin-db-user'}".

	--db-host		Your database host. Defaults to "$opts->{'db-host'}".

	--help			Displays this message.

	--no-cache		Do not write configuration options to the cache.

	--no-wre-restart	Do not restart WRE after removing the configuration.

	--sitename		The combined hostname and domain name of the site. For
				example "www.example.com".

	--wre-restart		The command line used to restart WRE. Defaults to
				"$opts->{'wre-restart'}".

STOP
}

