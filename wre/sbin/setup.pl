#!/data/wre/prereqs/perl/bin/perl

use lib '/data/wre/lib';
use strict;
use warnings;
use DBI;
use Parse::PlainConfig;
use File::Path;
use Hoster::Template;
use Sys::Hostname;
use Socket;

our (@crons, @diffs);
our $mysqlRootPassword;
our $mysqlRootUser;
our $mysqlHost;
our $mysqlPort;
our $apacheModPerlPort;
our $apacheModProxyPort;
our $spectreSubnets;
my $setupType = startup();
my $isDev = ($setupType eq "install" && prompt("Will this WRE be a dev only environment?","n","y","n") eq "y");
setupWre($setupType);
setupApache($setupType, $isDev);
setupMysql($setupType);
setupAwstats($setupType) unless ($isDev);
setupMonitors($setupType) unless ($isDev);
setupBackups($setupType) unless ($isDev);
setupWebgui($setupType);
setupDemo($setupType) unless ($isDev);
setupAsDev($setupType) if ($isDev);;
displayMessages();
if ($isDev) {
	printMessage("Setup Complete! Now you need to start the WRE and visit http://dev.localhost.localdomain/");
} elsif ($setupType eq "install") {
	printMessage("Setup Complete! Now you need to start the WRE and add your first site.");
} else {
	printMessage("Setup Complete!");
}

#----------------------------------------

sub displayMessages {
	if (scalar(@diffs)) {
		print "Some of your configs don't match the defaults. Run these diff commands to find out what's different:\n\t".join("\n\t",@diffs)."\n\n";
	}
	if (scalar(@crons)) {
		print "You need to add the following scripts to your cron tab:\n\t".join("\n\t",@crons)."\n\n";
	}
}


#----------------------------------------
sub setupApache {
	my $setupType = shift;
	my $isDev = shift;
	printMessage("Configuring Apache...");
	unless ($apacheModProxyPort) {
		$apacheModProxyPort = prompt("What port do you want to run ModProxy on:", 80);
	}
	my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
	$config->set('apache-modproxy-port'=>$apacheModProxyPort);
	$config->write;
	getModPerlPort();
	
	# create apache modperl configuration file from template
	if ($isDev) {
		createFileFromTemplate("/data/wre/var/setupfiles/httpd.modperl.conf.dev.template", "/data/wre/var/setupfiles/httpd.modperl.conf.dev");
		copyFile("/data/wre/var/setupfiles/httpd.modperl.conf.dev", "/data/wre/prereqs/apache/conf/httpd.modperl.conf");
	} else {
		createFileFromTemplate("/data/wre/var/setupfiles/httpd.modperl.conf.template", "/data/wre/var/setupfiles/httpd.modperl.conf");
		copyFile("/data/wre/var/setupfiles/httpd.modperl.conf", "/data/wre/prereqs/apache/conf/httpd.modperl.conf");	
	}
	# copy startup.pl
	copyFile("/data/wre/var/setupfiles/startup.pl", "/data/wre/prereqs/apache/conf/startup.pl");
	# create apache modproxy configuration file from template
	createFileFromTemplate("/data/wre/var/setupfiles/httpd.modproxy.conf.template", "/data/wre/var/setupfiles/httpd.modproxy.conf") ;
	copyFile("/data/wre/var/setupfiles/httpd.modproxy.conf", "/data/wre/prereqs/apache/conf/httpd.modproxy.conf");
	# create virtual host modperl template
	createFileFromTemplate("/data/wre/var/setupfiles/vh.modperl.template.template", "/data/wre/var/setupfiles/vh.modperl.template") ;
	copyFile("/data/wre/var/setupfiles/vh.modperl.template", "/data/wre/var/vh.modperl.template");
	# create virtual host modproxy template
	createFileFromTemplate("/data/wre/var/setupfiles/vh.modproxy.template.template", "/data/wre/var/setupfiles/vh.modproxy.template") ;
	copyFile("/data/wre/var/setupfiles/vh.modproxy.template", "/data/wre/var/vh.modproxy.template");
	print "\n\n" ;
}

#----------------------------------------
sub startMysql {
	if (getMysqlHost() eq "localhost") {
       		system("/data/wre/sbin/rc.webgui startmysql");
       		sleep 4;         #wait for mysql to start up
	}
}

#----------------------------------------
sub stopMysql {
	if (getMysqlHost() eq "localhost") {
       		system("/data/wre/sbin/rc.webgui stopmysql");
	}
}

#----------------------------------------
sub getModPerlPort {
	unless ($apacheModPerlPort) {
		$apacheModPerlPort = prompt("Please specify the port you want modperl to run on:","81");
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$config->set('apache-modperl-port'=>$apacheModPerlPort);
		$config->write;
	}
	return $apacheModPerlPort;
}

#----------------------------------------
sub getMysqlPort {
	unless ($mysqlPort) {
		$mysqlPort = prompt("Please specifiy the port MySQL listens on:","3306");
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$config->set('db-port'=>$mysqlPort);
		$config->write;
	}
	return $mysqlPort;
}

#----------------------------------------
sub getMysqlHost {
	unless ($mysqlHost) {
		$mysqlHost = prompt("Please specifiy the host where MySQL resides (if this is a single server install, leave the default):","localhost");
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$config->set('db-host'=>$mysqlHost);
		$config->write;
	}
	return $mysqlHost;
}

#----------------------------------------
sub getMysqlRootUser {
	unless ($mysqlRootUser) {
		$mysqlRootUser = prompt("Please specifiy your MySQL administratrative username:","root");
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$config->set('admin-db-user'=>$mysqlRootUser);
		$config->write;
	}
	return $mysqlRootUser;
}

#----------------------------------------
sub getMysqlRootPassword {
	unless ($mysqlRootPassword) {
		$mysqlRootPassword = prompt("Please specifiy the MySQL password for the ".getMysqlRootUser()." user:");
	}
	return $mysqlRootPassword;
}

#----------------------------------------
sub getSpectreSubnets {
	unless ($spectreSubnets) {
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		my $address = inet_ntoa(scalar gethostbyname( hostname() || 'localhost' )) . '/32' ;
		my $answer = prompt("What IP address(es) will WebGUI be serving requests on (for more than one \naddress please use a comma separated list of CIDR addresses):", $address);
		$answer =~ s/[^\d.,\/]//g ; # clean up input, but it still could be garbage
		my @subnets = split(",", $answer);
		push(@subnets, "127.0.0.1/32");
		$config->set('spectreSubnets'=>\@subnets);
		$spectreSubnets = \@subnets;
		$config->write;
	}
	return $spectreSubnets;
}

#----------------------------------------
sub connectToMysql {
	my (@dbi_args) = @_;
	my $dsn = "DBI:mysql:mysql;host=".getMysqlHost().";port=".getMysqlPort();

	# Hardcoded retry and delay values, bleh.
	my $orig_tries_max = 3;
	my $delay = 3;
	my ($tries, $cur_tries_max) = (0, $orig_tries_max);

	my $dbh;
	    
	while (1) {
		++$tries;
		$dbh = DBI->connect($dsn, @dbi_args);
		last if defined $dbh;

		if ($tries == $cur_tries_max) {
			my $response = prompt("Could not connect to the MySQL server after $tries tries.  Keep trying?", 'n', ('y', 'n'));
			if ($response eq 'y') {
				$cur_tries_max += $orig_tries_max;
				next;
			} else {
				last;
			}
		}
		printMessage("Could not connect to the MySQL server.");
	} continue {
		printMessage("Commencing try number ".($tries+1)." in $delay seconds...");
		sleep $delay;

		redo;
	}
	    

	if ($dbh) {
		printMessage("Connected to the MySQL server.");
	} else {
		printMessage("Could not connect to the MySQL server after $tries tries; giving up.");
	}

	return $dbh;
}

sub connectToMysqlAsRoot {
	# Tail call.
	@_ = (getMysqlRootUser(), getMysqlRootPassword());
	goto &connectToMysql;
}

#----------------------------------------
sub sudoPrefixTo {
	my ($uid) = @_;
	return "" if $< == $uid;
	return "sudo -p 'Password for sudo from \%u to \%U: ' -u \#$uid ";
}

#----------------------------------------
sub setupDemo {
        my $setupType = shift;
        if (-f "/data/wre/etc/demo.conf") {
                printMessage("Updating WRE Demo...");
                copyDemoFiles();
        } elsif (prompt("Do you want to configure the WRE demo system?","n","y","n") eq "y") {
                copyDemoFiles();
		my $pw = prompt("What would you like the demo admin password to be?");
		startMysql();
		my $dbh = connectToMysqlAsRoot();
		defined($dbh) or die "No database connection; giving up.\n";
		my $from = getMysqlHost() eq "localhost" ? "localhost" : "%";
		$dbh->do("grant all privileges on *.* to demoadmin\@'".$from."' identified by '".$pw."' with grant option");
		$dbh->disconnect;
		stopMysql();
		my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/demo.conf', 'PURGE' => 1);
		$config->set(adminpass=> $pw);
		$config->set(mysqlhost=>getMysqlHost());
		$config->set('db-port' => getMysqlPort());
		$config->set('spectreSubnets' => getSpectreSubnets()) ;
                my $site = prompt("What sitename will you use for the demo (like demo.example.com)?");
		$config->set('sitename' => $site);
		$config->write;
		my $sudo = sudoPrefixTo(0);
		system("$sudo mkdir -p /data/domains/demo");
		foreach my $dir ("/data/WebGUI/etc", "/data/domains/demo", "/data/wre/etc/demo.conf") {
			system("$sudo chown nobody $dir");
		}
                open(FILE,"</data/wre/etc/demo.modproxy");
                my $fileContents;
                while(my $line = <FILE>) {
                        if ($line =~ /ServerName/) {
                                $line = "\tServerName ".$site."\n";
			} elsif ($line =~ /RewriteRule/ && $line=~ /__demo-sitename__/) {
				$line =~ s/__demo-sitename__/$site/ ;
                        }
                        $fileContents .= $line;
                }
                close(FILE);
                open(FILE,">/data/wre/etc/demo.modproxy");
                print FILE $fileContents;
                close(FILE);
                open(FILE,"</data/wre/etc/demo.modperl");
                $fileContents = "";
                while(my $line = <FILE>) {
                        if ($line =~ /ServerName/) {
                                $line = "\tServerName ".$site."\n";
                        }
                        $fileContents .= $line;
                }
                close(FILE);
                open(FILE,">/data/wre/etc/demo.modperl");
                print FILE $fileContents;
                close(FILE);
		push(@crons, "0 0 * * * /data/wre/sbin/democleanup");
        }
}

#----------------------------------------
sub copyDemoFiles {
        createFileFromTemplate("/data/wre/var/setupfiles/demo.conf.template", "/data/wre/var/setupfiles/demo.conf") ;
	my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
	my $config1 = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/var/setupfiles/demo.conf', 'PURGE' => 1);
	$config1->set('spectreSubnets'=>getSpectreSubnets()) ;
	$config1->write() ;
        copyFile("/data/wre/var/setupfiles/demo.conf", "/data/wre/etc/demo.conf");
        createFileFromTemplate("/data/wre/var/setupfiles/demo.modproxy.template", "/data/wre/var/setupfiles/demo.modproxy") ;
        copyFile("/data/wre/var/setupfiles/demo.modproxy", "/data/wre/etc/demo.modproxy");
        createFileFromTemplate("/data/wre/var/setupfiles/demo.modperl.template", "/data/wre/var/setupfiles/demo.modperl") ;
        copyFile("/data/wre/var/setupfiles/demo.modperl", "/data/wre/etc/demo.modperl");
}

#----------------------------------------
sub setupAwstats {
	my $setupType = shift;
	if (-f "/data/wre/var/awstats.template.conf") {
		printMessage("Updating AWStats...");
		copyAwstatsFiles();
	} elsif (prompt("Do you want to configure the WRE web stats system?","y","y","n") eq "y") {
		copyAwstatsFiles();
		my $site = prompt("What sitename will you use for web stats (like stats.example.com)?");
		open(FILE,"</data/wre/etc/stats.modproxy");
		my $fileContents;
		while(my $line = <FILE>) {
			if ($line =~ /ServerName/) {
				$line = "\tServerName ".$site."\n";
			}
			$fileContents .= $line;
		}
		close(FILE);
		open(FILE,">/data/wre/etc/stats.modproxy");
		print FILE $fileContents;
		close(FILE);
		push(@crons, "0 2 * * * /data/wre/prereqs/awstats/tools/awstats_updateall.pl now -awstatsprog=/data/wre/prereqs/awstats/wwwroot/awstats.pl -configdir=/data/wre/etc");
	}
}

#----------------------------------------
sub copyAwstatsFiles {
	createFileFromTemplate("/data/wre/var/setupfiles/awstats.template.conf.template", "/data/wre/var/setupfiles/awstats.template.conf");
	copyFile("/data/wre/var/setupfiles/awstats.template.conf", "/data/wre/var/awstats.template.conf");
	createFileFromTemplate("/data/wre/var/setupfiles/stats.modproxy.template", "/data/wre/var/setupfiles/stats.modproxy");
	copyFile("/data/wre/var/setupfiles/stats.modproxy", "/data/wre/etc/stats.modproxy");
}

#----------------------------------------
sub setupMysql {
	my $setupType = shift;
	printMessage("Configuring MySQL...");
	if ($setupType eq "install" && getMysqlHost() eq "localhost") {
		$mysqlRootUser = prompt("What would you like the MySQL administrative user to be called:", "root");
		$mysqlRootPassword = prompt("What would you like the MySQL ".$mysqlRootUser." password to be?");
		$mysqlPort = prompt("What TCP/IP port you like MySQL to run on: ", 3306);
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$config->set('admin-db-user'=>$mysqlRootUser);
		$config->set('db-port'=>$mysqlPort);
		$config->write;
		# create my.cnf file from template
		createFileFromTemplate("/data/wre/var/setupfiles/my.cnf.template", "/data/wre/var/setupfiles/my.cnf");
		copyFile("/data/wre/var/setupfiles/my.cnf", "/data/wre/prereqs/mysql/my.cnf");
		system("ln -s /data/wre/prereqs/mysql/my.cnf /data/wre/prereqs/mysql/var/my.cnf");
        	system("cd /data/wre/prereqs/mysql; ./bin/mysql_install_db --port=" . $config->get('db-port'));
		my $sudo = sudoPrefixTo(0);
		system("$sudo chown mysql /data/wre/prereqs/mysql");
		system("$sudo chown -R mysql /data/wre/prereqs/mysql/var");
		startMysql();
		my $dbh = connectToMysql('root');
		defined($dbh) or die "No database connection; giving up.\n";
		$dbh->do("delete from user where user=''");
		$dbh->do("delete from user where user='root'");
		$dbh->do("grant all privileges on *.* to ".getMysqlRootUser()."\@'localhost' identified by '".getMysqlRootPassword()."' with grant option");
		$dbh->do("flush privileges");
		$dbh->disconnect;
		stopMysql();
	} elsif ($setupType eq "upgrade" && getMysqlHost() eq "localhost") {
		getMysqlPort();
		# create my.cnf file from template
		createFileFromTemplate("/data/wre/var/setupfiles/my.cnf.template", "/data/wre/var/setupfiles/my.cnf");
		copyFile("/data/wre/var/setupfiles/my.cnf", "/data/wre/prereqs/mysql/my.cnf");
		system("rm /data/wre/prereqs/mysql/var/my.cnf");
		system("ln -s /data/wre/prereqs/mysql/my.cnf /data/wre/prereqs/mysql/var/my.cnf");
	}
}

#----------------------------------------
sub setupWre {
	my $setupType = shift;
	printMessage("Configuring the WRE...");
	if ($setupType eq "install") {
		copyFile("/data/wre/var/setupfiles/hoster.arg.cache.template", "/data/wre/var/hoster.arg.cache");
	}
	if ($setupType eq "upgrade") {
		my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
		$mysqlRootUser = $config->get("admin-db-user");
		$mysqlHost = $config->get("db-host");
		$mysqlPort = $config->get("db-port");
		$apacheModPerlPort = $config->get("apache-modperl-port") ;
		$apacheModProxyPort = $config->get("apache-modproxy-port") ;
		$spectreSubnets = $config->get("spectreSubnets");
	}
	copyFile("/data/wre/var/setupfiles/logrotate.conf", "/data/wre/etc/logrotate.conf");
}

#----------------------------------------
sub setupAsDev {
	printMessage("Configuring as a Development Environment...");
	startMysql();
	system("/data/wre/sbin/addsite --no-wre-restart --sitename=dev.localhost.localdomain --admin-db-pass=".getMysqlRootPassword());
	stopMysql();
	printMessage("Please add the following line to your /etc/hosts file\n\n127.0.0.1 dev dev.localhost.localdomain\n\n");
	my $content = "";
	open(FILE,"</data/wre/etc/dev.localhost.localdomain.modproxy");
	while (my $line = <FILE>) {
		$line =~ s/http\:\/\/dev\.localhost\.localdomain\:/http\:\/\/127\.0\.0\.1\:/;
		$content .= $line;
	}
	close(FILE);
	open(FILE,">/data/wre/etc/dev.localhost.localdomain.modproxy");
	print FILE $content;
	close(FILE);
	$content = "";
	open(FILE,"</data/wre/etc/dev.localhost.localdomain.modperl");
	while (my $line = <FILE>) {
		$line =~ s/PerlInitHandler WebGUI/PerlModule Apache2\:\:Reload\nPerlInitHandler Apache2\:\:Reload WebGUI/;
		$content .= $line;
	}
	close(FILE);
	open(FILE,">/data/wre/etc/dev.localhost.localdomain.modperl");
	print FILE $content;
	close(FILE);
}

#----------------------------------------
sub setupMonitors {
	my $setupType = shift;
	printMessage("Configuring monitors...");
	my $config = Parse::PlainConfig->new('FILE' => '/data/wre/var/hoster.arg.cache', 'PURGE' => 1);
	if (!(-f "/data/wre/etc/wremonitor.conf") && getMysqlHost() eq "localhost") {
		startMysql();
		my $dbh = connectToMysqlAsRoot();
		defined($dbh) or die "No database connection; giving up.\n";
		$dbh->do("grant all privileges on test.* to test\@localhost identified by 'test'");
		$dbh->disconnect;
		stopMysql();
	}
	# create wremonitor.conf file from template
        createFileFromTemplate("/data/wre/var/setupfiles/wremonitor.conf.template", "/data/wre/var/setupfiles/wremonitor.conf") ;
	copyFile("/data/wre/var/setupfiles/wremonitor.conf", "/data/wre/etc/wremonitor.conf");
	if (getMysqlHost() ne "localhost") {
		my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/wremonitor.conf', 'PURGE' => 1);
		$config->set('skipdb'=>1);
		$config->write;
	}
}

#----------------------------------------
sub setupBackups {
	my $setupType = shift;
	printMessage("Configuring backups...");
	copyFile("/data/wre/var/setupfiles/backup.exclude", "/data/wre/etc/backup.exclude");
        createFileFromTemplate("/data/wre/var/setupfiles/backup.conf.template", "/data/wre/var/setupfiles/backup.conf") ;
	if (-f "/data/wre/etc/backup.conf") {
		copyFile("/data/wre/var/setupfiles/backup.conf", "/data/wre/etc/backup.conf");
	} else {
		copyFile("/data/wre/var/setupfiles/backup.conf", "/data/wre/etc/backup.conf");
		my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/backup.conf', 'PURGE' => 1);
		my $backuppw = prompt("What would you like the database backup password to be?");
		startMysql();
		my $dbh = connectToMysqlAsRoot();
		defined($dbh) or die "No database connection; giving up.\n";
		my $from = getMysqlHost() eq "localhost" ? "localhost" : "%";
		$dbh->do("grant select, lock tables, show databases on *.* to backup\@'".$from."' identified by '".$backuppw."'");
		$dbh->disconnect;
		stopMysql();
		$config->set(mysqlpass=> $backuppw);
		$config->set(mysqlhost=> getMysqlHost());
		$config->set('db-port'=>getMysqlPort()) ;
		$config->set(backupDir => prompt("Specify the path to backup the WRE and WebGUI data files to:","/backup"));
		if (prompt("Do you want to copy your backups to an FTP server?","n","y","n") eq "y") {
			$config->set(backupToFtp => 1);
			$config->set(ftphost => prompt("Specify the name of the server you want to copy to:"));
			$config->set(ftpuser => prompt("Specify the FTP user:"));
			$config->set(ftppass => prompt("Specify the FTP password:"));
			$config->set(ftppath => prompt("Specify the path on the FTP server to copy to:", "/backup"));
			$config->set(ftpCopiesToKeep => prompt("How many days worth of backups should be kept on the FTP server?", "3"));
		}
		$config->write;
	}
}

#----------------------------------------
sub setupWebgui {
	printMessage("Configuring WebGUI...");
	# initialize spectreSubnets for use in site configuration files
	getSpectreSubnets();
	copyFile("/data/wre/var/setupfiles/webgui.conf.override", "/data/wre/var/webgui.conf.override");
	if ($setupType eq "install") {
		system("/data/wre/sbin/webguiupdate");
		my $logConf = "";
		open(FILE,"</data/WebGUI/etc/log.conf.original");
		while (my $line = <FILE>) {
			$line =~ s/\/var\/log\/webgui.log/\/data\/wre\/var\/webgui.log/;
			$logConf .= $line;	
		}
		close(FILE);
		open(FILE,">/data/WebGUI/etc/log.conf");
		print FILE $logConf;
		close(FILE);
		my $spectreConf = "" ;
		open(FILE,"</data/WebGUI/etc/spectre.conf.original");
		while (my $line = <FILE>) {
			if ($line =~ /^"webguiPort" :/) {
				$line = '"webguiPort" : ' . getModPerlPort() . "\n" ;
			}
			$spectreConf .= $line;	
		}
		close(FILE);
		open(FILE,">/data/WebGUI/etc/spectre.conf");
		print FILE $spectreConf;
		close(FILE);
		my $sudo = sudoPrefixTo(0);
		system("$sudo touch /data/wre/var/webgui.log");
		system("$sudo chown nobody /data/wre/var/webgui.log");
	}
}

#----------------------------------------
sub createFileFromTemplate {
	my $from = shift; # template
	my $to = shift; # output file
	my $opts_file = "/data/wre/var/hoster.arg.cache";
	my $config = Parse::PlainConfig->new('FILE' => $opts_file, 'PURGE' => 1);
	my $opts = $config->get_ref ;
	open(FILE,">$to") ;
	print FILE Hoster::Template::parse(Hoster::Template::get($from),$opts);
	close(FILE);
}


#----------------------------------------
sub startup {
	printTest("Checking for existing install...");
	my ($old, $new) = "";
	if (open(FILE,"</data/wre/var/version.txt")) {
		$old = <FILE>;
		close(FILE);
	}
	if (open(FILE,"</data/wre/var/setupfiles/version.txt")) {
		$new = <FILE>;
		close(FILE);
	}
	my $type = "";
        if ($old eq $new) {
                $type = "done"; # already upgraded
		if (prompt("You've already run setup for this WRE version! Would you like to run setup again?","n","y","n") eq "y") {
			$type = "upgrade";
		} else {
			exit;
		}
        } elsif (-f "/data/wre/var/hoster.arg.cache" || $old ne "") {
                $type = "upgrade"; # must upgrade
		printResult("Looks like we need to upgrade.");
        } else {
		push(@crons, "0 1 * * * /data/wre/sbin/logrotate");
		push(@crons, "*/3 * * * * /data/wre/sbin/wremonitor");
		push(@crons, "0 3 * * * /data/wre/sbin/backup");
                $type = "install"; # new install
		printResult("Looks like a new install.");
        }
	system("cp -f /data/wre/var/setupfiles/version.txt /data/wre/var/version.txt");
	return $type;
}

#----------------------------------------
sub failAndExit {
        my $exitmessage = shift;
        print $exitmessage."\n\n";
        exit;
}

#----------------------------------------
sub isIn {
        my $key = shift;
        $_ eq $key and return 1 for @_;
        return 0;
}

#----------------------------------------
sub printTest {
        my $test = shift;
        print sprintf("%-45s", $test.": ");
}

#----------------------------------------
sub printMessage {
        my $message = shift;
        print "$message\n";
}

#----------------------------------------
sub printResult {
        my $result = shift || "OK";
        print "$result\n";
}

#----------------------------------------
sub prompt {
        my $question = shift;
        my $default = shift;
        my @answers = @_; # the rest are answers
        print "\n".$question." ";
        print "{".join("|",@answers)."} " if ($#answers > 0);
        print "[".$default."] " if (defined $default);
        my $answer = <STDIN>;
        chomp $answer;
        $answer = $default if ($answer eq "");
        $answer = prompt($question,$default,@answers) if (($#answers > 0 && !(isIn($answer,@answers))) || $answer eq "");
        return $answer;
}

#----------------------------------------
sub copyFile {
	my $from = shift;
	my $to = shift;
	if ( -f $to) {
		my @tomd5 = split(" ",`/data/wre/sbin/md5sum $to`);
		my @frommd5 = split(" ",`/data/wre/sbin/md5sum $from`);
		unless ($tomd5[0] eq $frommd5[0]) {
			push(@diffs, "diff $to $from");
		}
	} else {
		system("cp $from $to");
	}	
}
