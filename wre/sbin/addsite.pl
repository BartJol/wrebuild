#!/data/wre/prereqs/perl/bin/perl

my $wreRoot = '/data/wre';

use lib $wreRoot.'/lib';
use strict;
use WRE::Config;
use GetOpt::Long;
use Hoster::AWStats;
use Hoster::Opts;
use Hoster::VirtualHost;
use Hoster::WebGUIConfig;
use Hoster::WebRoot;
use Hoster::WebGUIDatabase;

$| = 1; 

my $config = WRE::Config->new($wreRoot);
my $options = WRE::Option->new($config, {
	sitename	=> {},
	var1		=> "s",
	var2		=> "s",
	var3		=> "s",
	var4		=> "s",
	var5		=> "s",
	var6		=> "s",
	var7		=> "s",
	var8		=> "s",
	var9		=> "s",
	var0		=> "s",
	});

my $modperl = WRE::ApacheVirtualHost->new($config, $args

my $opts = Hoster::Opts::get('/data/wre');
if ($opts->{help}) {
	help($opts);
	exit;
}
$opts = Hoster::Opts::generate($opts);
if ($opts->{'print-vars'}) {
	Hoster::Opts::printVars($opts);
	exit;
}
if ($opts->{'print-values'}) {
	Hoster::Opts::printValues($opts);
	exit;
}
if ($opts->{sitename} eq "" || $opts->{'admin-db-pass'} eq "") {
	help($opts);
	exit;
}

Hoster::VirtualHost::create($opts);
Hoster::AWStats::create($opts);
Hoster::WebRoot::create($opts);
Hoster::WebGUIConfig::create($opts);
Hoster::WebGUIDatabase::create($opts);
system($opts->{'wre-restart'}) unless ($opts->{'no-wre-restart'});


#------------------------------
sub help {
	my $opts = $_[0];
	print <<STOP;

WRE: Add A Site - Copyright 2003-2006 Plain Black Corporation

Usage: $0 --sitename=www.example.com --admin-db-pass=PASSWORD

Options:
	--admin-db-pass		The password for admin-db-user.

	--admin-db-user		The database user that has rights to create new
				databases and grant privileges. Defaults to "$opts->{'admin-db-user'}".

	--apache-user		The user that Apache runs as. Defaults to "$opts->{'apache-user'}".

	--chown			The path to your system's chown script. Defaults to
				"$opts->{'chown'}".

	--db-host		Your database host. Defaults to "$opts->{'db-host'}".

	--gateway-template	The name of the file to use as a template for the WebGUI
				gateway application. Defaults to "$opts->{'gateway-template'}".

	--help			Displays this message.

	--no-wre-restart	Do not restart WRE after creating the configuration.

	--no-cache		Do not write configuration options to the cache.

	--print-vars		Displays a list of template vars that could be used when
				parsing templates. To use this you must specify a full
				working command line. The program will exit without running
				the command.

	--site-db-pass		The password to use on the database for this site.
				Defaultly generates a random password.

	--site-db-user		The username to use on the database for this site.
				Defaultly generates a random username.

	--sitename		The combined hostname and domain name of the site. For
				example "www.example.com".

	--var[n]		Create a template variable where n is 0-9. Using "--var1",
				for example, would create "__var1__" for template
				processing.

	--vh-modperl-template	The name of the template file to use for mod_perl virtual 
				hosts. Defaults to "$opts->{'vh-modperl-template'}".

	--vh-modproxy-template	The name of the template file to use for mod_proxy virtual 
				hosts. Defaults to "$opts->{'vh-modproxy-template'}".

	--webgui-conf-template	The name of the file to use as a template for overriding
				the parameters in WebGUI.conf.original in the WebGUI install.
				Defaults to "$opts->{'webgui-conf-template'}".

	--wre-restart		The command line used to restart WRE. Defaults to
				"$opts->{'wre-restart'}".

STOP
}

