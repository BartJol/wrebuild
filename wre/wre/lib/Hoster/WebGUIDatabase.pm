package Hoster::WebGUIDatabase;

use strict;

#------------------------------
sub create {
	my ($opts) = @_;
	my $cmd = $opts->{'mysql-client'};
	if ($opts->{'db-port'}) {
		$cmd .= ' --port='.$opts->{'db-port'};
	}
	if ($opts->{'admin-db-user'}) {
		$cmd .= ' -u'.$opts->{'admin-db-user'};
	}
	if ($opts->{'admin-db-pass'}) {
		$cmd .= ' -p'.$opts->{'admin-db-pass'};
	}
	my $from = ($opts->{'db-host'} eq "localhost") ? "localhost" : "%";
	$cmd .= ' --host='.$opts->{'db-host'}.' -e "create database '.$opts->{'db-name'}.'; grant all privileges on '.$opts->{'db-name'}
		.'.* to '.$opts->{'site-db-user'}."\@'".$from."' identified by '".$opts->{'site-db-pass'}.'\'"';
	system($cmd);
	$cmd = $opts->{'mysql-client'}.' --host='.$opts->{'db-host'}.' -D '.$opts->{'db-name'};
	if ($opts->{'db-port'}) {
		$cmd .= ' --port='.$opts->{'db-port'};
	}
	if ($opts->{'site-db-user'}) {
		$cmd .= ' -u'.$opts->{'site-db-user'};
	}
	if ($opts->{'site-db-pass'}) {
		$cmd .= ' -p'.$opts->{'site-db-pass'};
	}
	$cmd .= ' < '.$opts->{'webgui-home'}.'/docs/create.sql';
	system($cmd);
}

#------------------------------
sub destroy {
	my ($opts) = @_;
	my $cmd = $opts->{'mysql-client'};
	if ($opts->{'db-port'}) {
		$cmd .= ' --port='.$opts->{'db-port'};
	}
	if ($opts->{'admin-db-user'}) {
		$cmd .= ' -u'.$opts->{'admin-db-user'};
	}
	if ($opts->{'admin-db-pass'}) {
		$cmd .= ' -p'.$opts->{'admin-db-pass'};
	}
	$cmd .= ' --host='.$opts->{'db-host'}.' -e "drop database '.$opts->{'db-name'}.'; use mysql; delete from user where user=\''.$opts->{'site-db-user'}
		.'\'; delete from db where user=\''.$opts->{'site-db-user'}.'\'"';
	system($cmd);
}

1;

