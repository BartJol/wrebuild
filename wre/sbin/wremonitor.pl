#!/data/wre/prereqs/perl/bin/perl

$| = 1;

use strict;
use Net::SMTP;
use Parse::PlainConfig;
use Proc::ProcessTable;
use DBI;
use HTTP::Request;
use HTTP::Headers;
use LWP::UserAgent;
use FileHandle;

my $config = getConfig();
unless ($config->{skipdb}) {
	unless (checkDb($config)) {
		logEntry("Database server reported down. Starting the critical monitor.");
		startCriticalDbMonitor($config);
	} else {
		logEntry("All is well with the database server.");
	}
}
unless ($config->{skipweb}) {
	unless (checkWeb($config)) {
		logEntry("Web server reported down. Starting the critical monitor.");
		startCriticalWebMonitor($config);
	} else {
		logEntry("All is well with the web server.");
	}
}
unless ($config->{skiphttpdrunaway}) {
        checkWebProcesses($config);
}
unless ($config->{skipspectre}) {
	unless (checkSpectre($config)) {
		logEntry("Spectre server reported down. Starting the critical monitor.");
		startCriticalSpectreMonitor($config);
	} else {
		logEntry("All is well with the Spectre server.");
	}
}
        
exit;

#-------------------------------------------------------------------
sub getConfig {
        my $config = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => '/data/wre/etc/wremonitor.conf', 'PURGE' => 1);
        my %data;
        foreach my $key ($config->directives) {
                $data{$key} = $config->get($key);
        }
        return \%data;
}

#-------------------------------------------------------------------
sub redAlertDb {
	my $config = shift;
        logEntry ("Database server down!");
        if (doDbRestart($config)) {
                sendEmail("The database server was down; wremonitor issued a restart and everything seems OK, but you should probably check it just the same.",$config);
                logEntry ("Database restart succeeded.");
        } else {
                sendEmail("The database server is down; wremonitor issued a restart, but the restart failed.",$config);
                logEntry ("Database restart failed.");
        }
}

#-------------------------------------------------------------------
sub checkDb {
	my $config = shift;
        my $dbh;
        if (eval { $dbh = DBI->connect($config->{dsn},$config->{dbuser},$config->{dbpass})} ) {
                $dbh->disconnect;
                return 1;
        } else {
                logEntry($@);
                return 0;
        }
}

#-------------------------------------------------------------------
sub checkWebProcesses {
  my $config = shift;
  my $allIsWell = 1;
  my $processTable = new Proc::ProcessTable;
  foreach my $process (@{$processTable->table}) {
    next unless ($process->cmndline =~ /httpd.* -D WRE-mod(proxy|perl) /);

    #for some reason the pctmem method reports x.4% as x.0%... FYI
    if (my $mem = $process->pctmem >= $config->{httpdMaxMemory}) {
       my $numKilled = $process->kill(9);

       #note num killed can exceed one process if its the parent, but that shouldn't happen
       if ($numKilled > 0) {
         logEntry("$numKilled runaway httpd processes killed for using $mem percent of shared memory.");
       }
       else {
         logEntry("Failed to kill runaway httpd processes using $mem percent of shared memory!");
       }
       $allIsWell = 0;
    }
  } 

  logEntry("All is well with httpd memory usage.") if ($allIsWell);

}

#-------------------------------------------------------------------
sub checkSpectre {
	my $config = shift;
	my $check = `source /data/wre/sbin/setenvironment; cd /data/WebGUI/sbin ; perl spectre.pl --ping` ;
        if ($check =~ /^Spectre is Alive!/ ) {
                return 1;
        } else {
                logEntry($check);
                return 0;
        }
}

#-------------------------------------------------------------------
sub startCriticalSpectreMonitor {
	my $config = shift;
	fork and exit;
	sleep(10);
	for(1..4) {
        	unless (checkSpectre($config)) {
			redAlertSpectre($config);
        	} else {
                	logEntry("Spectre server is well once again.");
			exit;
        	}
        	sleep($config->{secondsBetweenChecks});
	}
}

#-------------------------------------------------------------------
sub redAlertSpectre{
        logEntry("Spectre server down!");
        if (doSpectreRestart($config)) {
                sendEmail("The Spectre server was down; wremonitor issued a restart and everything seems OK, but you should probably check it just the same.",$config);
                logEntry ("Spectre server restart succeeded.");
        } else {
                sendEmail("The Spectre server is down; wremonitor issued a restart, but the restart failed.",$config);
                logEntry ("Spectre server restart failed.");
        }
}

#-------------------------------------------------------------------
sub doSpectreRestart {
        if (system("/data/wre/sbin/rc.webgui restartspectre")) {
                return 0;
        } else {
                return 1;
        }
}

#-------------------------------------------------------------------
sub startCriticalDbMonitor {
        my $config = shift;
        fork and exit;
        sleep(10);
        for(1..4) {
                unless (checkDb($config)) {
                        redAlertDb($config);
                } else {
                        logEntry("Database server is well once again.");
                        exit;
                }
                sleep($config->{secondsBetweenChecks});
        }
}

#-------------------------------------------------------------------
sub startCriticalWebMonitor {
	my $config = shift;
	fork and exit;
	sleep(10);
	for(1..4) {
        	unless (checkWeb($config)) {
			redAlertWeb($config);
        	} else {
                	logEntry("Web server is well once again.");
			exit;
        	}
        	sleep($config->{secondsBetweenChecks});
	}
}

#-------------------------------------------------------------------
sub redAlertWeb {
        logEntry("Web server down!");
        if (doWebRestart($config)) {
                sendEmail("The web server was down; wremonitor issued a restart and everything seems OK, but you should probably check it just the same.",$config);
                logEntry ("Web server restart succeeded.");
        } else {
                sendEmail("The web server is down; wremonitor issued a restart, but the restart failed.",$config);
                logEntry ("Web server restart failed.");
        }
}

#-------------------------------------------------------------------
sub checkWeb {
	my $config = shift;
        my $userAgent = new LWP::UserAgent;
        $userAgent->agent("wremonitor/1.0");
        $userAgent->timeout($config->{connectionTimeOut});
        my $header = new HTTP::Headers;
        my $requestproxy = new HTTP::Request (GET => "http://".$config->{hostname}.":".$config->{modproxyPort}."/", $header);
        my $requestperl = new HTTP::Request (GET => "http://".$config->{hostname}.":".$config->{modperlPort}."/", $header);
        my $responseproxy = $userAgent->request($requestproxy);
        my $responseperl = $userAgent->request($requestperl);
        if (($responseproxy->is_success || $responseproxy->code eq "401") && ($responseperl->is_success || $responseperl->code eq "401")) {
                return 1;
	} elsif ($responseproxy->is_success) {
		logEntry($responseperl->code);
		logEntry($responseperl->error_as_HTML);
                return 0;
        } else {
		logEntry($responseproxy->code);
                logEntry($responseproxy->error_as_HTML);
                return 0;
        }
}

#-------------------------------------------------------------------
sub doWebRestart {
	my $config = shift;
	my $restartCommand = $config->{ipcs}.' -s | '.$config->{'grep'}.' apache | /data/wre/prereqs/perl/bin/perl -e \'while (<STDIN>) { @a=split(/\s+/); print `ipcrm sem $a[1]`}\';/data/wre/sbin/rc.webgui restartweb';
        if (system($restartCommand)) {
                return 0;
        } else {
                return 1;
        }
}

#-------------------------------------------------------------------
sub doDbRestart {
        if (system("/data/wre/sbin/rc.webgui restartmysql")) {
                return 0;
        } else {
                return 1;
        }
}

#-------------------------------------------------------------------
sub logEntry {
	my $message = shift;
        my $log = FileHandle->new(">>/data/wre/var/wremonitor.log") or die "Can't open log file.";
        print $log localtime()." - ".$message."\n";
        $log->close;
}

#-------------------------------------------------------------------
sub sendEmail {
	my $message = shift;
	my $config = shift;
        my $smtp = Net::SMTP->new($config->{smtpServer});
        if (defined $smtp) {
                $smtp->mail($config->{adminEmail});
                $smtp->to($config->{adminEmail});
                $smtp->data();
                $smtp->datasend("To: ".$config->{adminEmail}."\n");
                $smtp->datasend("From: WRE Monitor <".$config->{adminEmail}.">\n");
                $smtp->datasend("Subject: ".$config->{hostname}." WRE Service DOWN!\n");
                $smtp->datasend("\n");
                $smtp->datasend($message);
		$smtp->datasend("\n");
		$smtp->datasend($config->{hostname});
		$smtp->datasend("\n");
                $smtp->dataend();
                $smtp->quit;
        } else {
                logEntry("Error: Cannot connect to mail server.");
        }
}

