#!/data/wre/prereqs/bin/perl

#-------------------------------------------------------------------
# WRE is Copyright 2005-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com	            		info@plainblack.com
#-------------------------------------------------------------------

use strict;
use lib '../lib';
use Carp qw(carp croak);
use CGI;
use Digest::MD5;
use File::Slurp;
use HTTP::Daemon;
use HTTP::Response;
use HTTP::Status;
use JSON qw(objToJson jsonToObj);
use Path::Class;
use Sys::Hostname;
use Socket;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Mysql;
use WRE::Spectre;


#-------------------------------------------------------------------
# server daemon
my $daemon = HTTP::Daemon->new(
    ReusePort   => 1,
    ReuseAddr   => 1,
    MultiHomed  => 1,
    LocalAddr   => undef,
    LocalPort   => 60834,
    ) || croak "Couldn't start server.";
print "Please contact me at: <URL:", $daemon->url, ">\n";
while (my $connection = $daemon->accept) {
    while (my $request = $connection->get_request) {
        my $state = {
            request     => $request,
            connection  => $connection,
            daemon      => $daemon,
            config      => WRE::Config->new,
            cgi         => parseRequest($request),
        };
        my $handler = $request->url->path;
        $handler =~ s{^/(.*)}{$1};
        if ($handler eq "" || $handler !~ m/^[A-Za-z]+$/) {
            $handler = "listSites";
        }
        $handler = "www_".$handler;
        no strict;
        &$handler($state);
        use strict;
    }
    $connection->close;
    undef($connection);
}

#-------------------------------------------------------------------
# this takes care of www_ methods that are called accidentally or maliciously
sub AUTOLOAD {
	our $AUTOLOAD;
    www_listSites(@_);
}


#-------------------------------------------------------------------
sub findSubnet {
    inet_ntoa(scalar gethostbyname( hostname() || 'localhost' )) . '/32' ; 
}

#-------------------------------------------------------------------
sub getNavigation {
    my $section = shift || "sites";
    my $toggle = 'class="sectionOn"';
    my $sites = ($section eq "sites") ? $toggle : '';
    my $services = ($section eq "services") ? $toggle : '';
    my $settings = ($section eq "settings") ? $toggle : '';
    my $templates = ($section eq "templates") ? $toggle : '';
    my $utilities = ($section eq "utilities") ? $toggle : '';
    my $content = qq|
    <div id="tabsWrapper">
    <a href="/listSites" $sites>Sites</a>
    <a href="/listServices" $services>Services</a>
    <a href="/editSettings" $settings>Settings</a>
    <a href="/listTemplates" $templates>Templates</a>
    <a href="/listUtilities" $utilities>Utilities</a>
    <div id="logo">WRE Console</div>
    <div id="navUnderline"></div>
    </div>
    |;
    return $content;
}

#-------------------------------------------------------------------
sub makeHtmlFormSafe {
    my $htmlRef = shift;
    ${$htmlRef} =~ s/\&/&amp;/xmsg;
    ${$htmlRef} =~ s/\>/&gt;/xmsg;
    ${$htmlRef} =~ s/\</&lt;/xmsg;
}

#-------------------------------------------------------------------
sub parseRequest {
    my $request = shift;
    my $method = $request->method;
    if ( $method eq 'GET' || $method eq 'HEAD' ) {
        return CGI->new( $request->uri->equery );
    }
    elsif ( $method eq 'POST' ) {
        my $contentType = $request->content_type;
        if ( ! $contentType || $contentType eq "application/x-www-form-urlencoded" ) {
            return CGI->new( $request->content );
        }
        elsif ( $contentType eq "multipart/form-data") {
            carp "Can't process multi-part data.";
        }
        else {
            carp "Invalid content type: $contentType";
        }
    }
    else {
        carp "Unsupported method: $method"; 
    }
    return {};
}

#-------------------------------------------------------------------
sub sendResponse {
    my $state = shift;
    my $content = shift;
    $content = '<html><head><title>WRE Console</title><link rel="stylesheet" href="/css" type="text/css"
    /></head> <body><div id="contentWrapper">'.$content.'</div><div id="footerOverline"></div><div id="credits">&copy; 2005-2007 <a
    href="http://www.plainblack.com/">Plain Black Corporation</a>. All rights reserved.</div></body></html>';
    my $response = HTTP::Response->new();
    $response->header("Content-Type" => "text/html");
    $response->content($content);
    $state->{connection}->send_response($response);
    $state->{connection}->force_last_request;
}


#-------------------------------------------------------------------
sub www_css {
    my $state = shift;
    $state->{connection}->send_file_response($state->{config}->getRoot("/var/wreconsole.css"));
}

#-------------------------------------------------------------------
sub www_addSite {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("sites");
    my $cgi = $state->{cgi};
    $content .= '
    <h1>Add A Site</h1>
    <div class="status">'.$status.'</div>
    <p>Adding a site requires you to restart modperl, modproxy, and Spectre.</p>
    <form action="/addSiteSave" method="post">
    <table class="items">
    <tr>
        <td>Admin Database Password</td>
        <td><input type="password" name="adminPassword" value="'.$cgi->param("adminPassword").'" /><span class="subtext">Required</span></td>
    </tr>
    <tr>
        <td>Site Name</td>
        <td><input type="text" name="sitename" value="'.$cgi->param("sitename").'" /><span class="subtext">Required</span></td>
    </tr>
    <tr>
        <td>Site Database User</td>
        <td><input type="text" name="siteDatabaseUser" value="'.$cgi->param("siteDatabaseUser").'" /><span class="subtext">Will be auto generated if left
        blank.</span></td>
    </tr>
    <tr>
        <td>Site Database Password</td>
        <td><input type="password" name="siteDatabasePassword" value="'.$cgi->param("siteDatabasePassword").'" /><span class="subtext">Will be auto generated if
        left blank.</td>
    </tr>
    <tr>
        <td>Custom Variables</td>
        <td>
            var0 <input type="text" name="var0" value="'.$cgi->param("var0").'" /><br />
            var1 <input type="text" name="var1" value="'.$cgi->param("var1").'" /><br />
            var2 <input type="text" name="var2" value="'.$cgi->param("var2").'" /><br />
            var3 <input type="text" name="var3" value="'.$cgi->param("var3").'" /><br />
            var4 <input type="text" name="var4" value="'.$cgi->param("var4").'" /><br />
            var5 <input type="text" name="var5" value="'.$cgi->param("var5").'" /><br />
            var6 <input type="text" name="var6" value="'.$cgi->param("var6").'" /><br />
            var7 <input type="text" name="var7" value="'.$cgi->param("var7").'" /><br />
            var8 <input type="text" name="var8" value="'.$cgi->param("var8").'" /><br />
            var9 <input type="text" name="var9" value="'.$cgi->param("var9").'" /><br />
        </td>
    </tr>
    </table>
    <input type="submit" value="Create Site" onclick="this.value=\'Please wait...\';" />
    </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_addSiteSave {
    my $state = shift;
    my $cgi = $state->{cgi};
    my $site = WRE::Site->new($state->{config}, $cgi->param("sitename"), $cgi->param("adminPassword"));
    if ($site->checkCreationSanity) {
        $site->create({
            siteDatabaseUser        => $cgi->param("siteDatabaseUser"),
            siteDatabasePassword    => $cgi->param("siteDatabasePassword"),
            var0                    => $cgi->param("var0"),
            var1                    => $cgi->param("var1"),
            var2                    => $cgi->param("var2"),
            var3                    => $cgi->param("var3"),
            var4                    => $cgi->param("var4"),
            var5                    => $cgi->param("var5"),
            var6                    => $cgi->param("var6"),
            var7                    => $cgi->param("var7"),
            var8                    => $cgi->param("var8"),
            var9                    => $cgi->param("var9"),
            });
        return www_listSites($state, $site->getSitename." was created. Don't forget to restart the web servers and Spectre.");
    } else {
        return www_addSite($state, "Site could not be created because ".$!);
    }
}

#-------------------------------------------------------------------
sub www_deleteSite {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/} || $filename eq "spectre.conf" || $filename eq "log.conf") {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $status = $sitename." deleted.";
    www_listSites($state, $status); 
}

#-------------------------------------------------------------------
sub www_editSettings {
    my $state = shift;
    my $config = $state->{config};
    my $content = getNavigation("settings");
    my $configOverrides = objToJson($config->get("webgui")->{configOverrides}, 
        {pretty => 1, indent => 4, autoconv=>0, skipinvalid=>1}); 
    my $wreMonitor = $config->get("wreMonitor");
    my $backup = $config->get("backup");
    my $demo = $config->get("demo");
    makeHtmlFormSafe(\$configOverrides); 
    $content .= '<form method="post" action="/editSettingsSave">
        <p><input type="submit" class="saveButton" value="Save" /></p>

        <fieldset><legend>Apache</legend>

        <p>
        Default Hostname<br />
        <input type="text" name="apacheDefaultHostname" value="'.$config->get("apache")->{defaultHostname}.'" /> 
        <span class="subtext">The hostname the WRE will check to see if Apache is alive. </span>
        </p>

        <p>
        Connection Timeout<br />
        <input type="text" name="apacheConnectionTimeout" value="'.$config->get("apache")->{connectionTimeout}.'" /> 
        <span class="subtext">How long the WRE will wait when checking to see if Apache is alive before
        deciding to give up.</span>
        </p>

        <p>
        Max Memory<br />
        <input type="text" name="apacheMaxMemoryPercent" value="'.$config->get("apache")->{maxMemoryPercent}.'" /> 
        <span class="subtext">The percentage of the servers memory that the WRE will allow Apache processes
        to use before killing them.</span>
        </p>

        </fieldset>
        
        <p><input type="submit" class="saveButton" value="Save" /></p>

        <fieldset><legend>WebGUI</legend>

        <p>
        Config File Overrides<br />
        <textarea name="webguiConfigOverrides">'.$configOverrides.'</textarea> 
        <span class="subtext">What settings should be overriden in the default WebGUI config file when creating a
        new site.</span>
        </p>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>WRE Monitor</legend>

        <p>
        Email Address<br />
        <input type="text" name="wreMonitorNotify" value="'.join(", ", @{$wreMonitor->{notify}}).'" /> 
        <span class="subtext">Email address to alert when site goes down. Comma separated list.</span>
        </p>

        <p>
        Seconds Between Checks<br />
        <input type="text" name="wreMonitorSecondsBetweenChecks" value="'.$wreMonitor->{secondsBetweenChecks}.'" /> 
        <span class="subtext">After an alert has been sounded, how long to wait until checking again to see if its
        back up.</span>
        </p>

        <p>
        Items To Monitor<br />
        <input type="radio" name="wreMonModproxy" value="1" '.(($wreMonitor->{items}{modproxy} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonModproxy" value="0" '.(($wreMonitor->{items}{modproxy} != 1) ? 'checked="1"' : '').' />No
        - modproxy<br />
        <input type="radio" name="wreMonModperl" value="1" '.(($wreMonitor->{items}{modperl} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonModperl" value="0" '.(($wreMonitor->{items}{modperl} != 1) ? 'checked="1"' : '').' />No
        - modperl<br />
        <input type="radio" name="wreMonMysql" value="1" '.(($wreMonitor->{items}{mysql} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonMysql" value="0" '.(($wreMonitor->{items}{mysql} != 1) ? 'checked="1"' : '').' />No
        - MySQL<br />
        <input type="radio" name="wreMonSpectre" value="1" '.(($wreMonitor->{items}{spectre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonSpectre" value="0" '.(($wreMonitor->{items}{spectre} != 1) ? 'checked="1"' : '').' />No
        - Spectre<br />
        <input type="radio" name="wreMonRunaway" value="1" '.(($wreMonitor->{items}{runaway} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="wreMonRunaway" value="0" '.(($wreMonitor->{items}{runaway} != 1) ? 'checked="1"' : '').' />No
        - Runaway Processes<br />
        </p>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
        <fieldset><legend>Backups</legend>

        <p>
        Path<br />
        <input type="text" name="backupPath" value="'.$backup->{path}.'" /> 
        <span class="subtext">The path to the folder you wish to back up files to.</span>
        </p>

        <p>
        Rotations<br />
        <input type="text" name="backupRotations" value="'.$backup->{rotations}.'" /> 
        <span class="subtext">How many copies of the backup should we keep at one time.</span>
        </p>

        <p>
        Compress<br />
        <input type="radio" name="backupCompress" value="1" '.(($backup->{compress} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupCompress" value="0" '.(($backup->{compress} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the backup be compressed.</span>
        </p>

        <p>
        Items To Backup<br />
        <input type="radio" name="backupFullWre" value="1" '.(($backup->{items}{fullWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFullWre" value="0" '.(($backup->{items}{fullWre} != 1) ? 'checked="1"' : '').' />No
        - modproxy<br />
        <input type="radio" name="backupSmallWre" value="1" '.(($backup->{items}{smallWre} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupSmallWre" value="0" '.(($backup->{items}{smallWre} != 1) ? 'checked="1"' : '').' />No
        - modperl<br />
        <input type="radio" name="backupDomains" value="1" '.(($backup->{items}{domainsFolder} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupDomains" value="0" '.(($backup->{items}{domainsFolder} != 1) ? 'checked="1"' : '').' />No
        - MySQL<br />
        <input type="radio" name="backupWebgui" value="1" '.(($backup->{items}{webgui} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupWebgui" value="0" '.(($backup->{items}{webgui} != 1) ? 'checked="1"' : '').' />No
        - Spectre<br />
        <input type="radio" name="backupMysql" value="1" '.(($backup->{items}{mysql} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupMysql" value="0" '.(($backup->{items}{mysql} != 1) ? 'checked="1"' : '').' />No
        - Runaway Processes<br />
        </p>

        <fieldset><legend>FTP</legend>
        <p>
        Enabled<br />
        <input type="radio" name="backupFtpEnabled" value="1" '.(($backup->{ftp}{enabled} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFtpEnabled" value="0" '.(($backup->{ftp}{enabled} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the backup be pushed to an FTP server.</span>
        </p>

        <p>
        Passive Transfers<br />
        <input type="radio" name="backupFtpPassive" value="1" '.(($backup->{ftp}{usePassiveTransfers} == 1) ? 'checked="1"' : '').' />Yes 
        <input type="radio" name="backupFtpPassive" value="0" '.(($backup->{ftp}{usePassiveTransfers} != 1) ? 'checked="1"' : '').' />No
        <span class="subtext">Should the FTP use passive transfers.</span>
        </p>

        <p>
        Rotations<br />
        <input type="text" name="backupFtpRotations" value="'.$backup->{ftp}{rotations}.'" /> 
        <span class="subtext">How many copies of the backup should we keep on the FTP server at one time.</span>
        </p>

        <p>
        Path<br />
        <input type="text" name="backupFtpPath" value="'.$backup->{ftp}{path}.'" /> 
        <span class="subtext">The path to the folder on the FTP server you wish to back up files to.</span>
        </p>

        <p>
        Auth<br />
        <input type="text" name="backupFtpUser" value="'.$backup->{ftp}{user}.'" /> 
        <input type="password" name="backupFtpPassword" value="'.$backup->{ftp}{password}.'" /> 
        <span class="subtext">The username and password of the FTP server.</span>
        </p>

        </fieldset>

        </fieldset>

        <p><input type="submit" class="saveButton" value="Save" /></p>
    </form>';
    return sendResponse($state, $content);
}



#-------------------------------------------------------------------
sub www_editTemplate {
    my $state = shift;
    my $content = getNavigation("templates");
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.template$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $template;
    eval { $template = read_file($state->{config}->getRoot("/var/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$template);
    $content .= '
        <form action="/editTemplateSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> 
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="template">'.$template.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> 
        </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.template$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $status = $filename." saved.";
    eval { write_file($state->{config}->getRoot("/var/".$filename), $state->{cgi}->param("template")) };
    if ($@) {
        $status = "Couldn't save $filename. $@";
        carp $status;
    }
    www_listTemplates($state, $status);
}

#-------------------------------------------------------------------
sub www_editSite {
    my $state = shift;
    my $content = getNavigation("sites");
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/} || $filename eq "spectre.conf" || $filename eq "log.conf") {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $contents;
    eval { $contents = read_file($state->{config}->getWebguiRoot("/etc/".$filename)) };
    if ($@) {
        carp "Couldn't open template file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <p>Making a modification of these files requires a restart of modperl and modproxy afterwards, and sometimes also a restart
        of Spectre after that.</p>
        <form action="/editSiteSave" method="post">
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
        <input type="hidden" name="filename" value="'.$filename.'" />
        <div><b>'.$filename.'</b></div>
        <textarea name="webgui">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" />  <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/".$sitename.".modproxy")) };
    if ($@) {
        carp "Couldn't open $sitename.modproxy file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>'.$sitename.'.modproxy</b></div>
        <textarea name="modproxy">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/".$sitename.".modperl")) };
    if ($@) {
        carp "Couldn't open $sitename.modperl file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>'.$sitename.'.modperl</b></div>
        <textarea name="modperl">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> <br /><br />
    ';
    eval { $contents = read_file($state->{config}->getRoot("/etc/awstats.".$sitename.".conf")) };
    if ($@) {
        carp "Couldn't open awstats.$sitename.conf file for editing $@";
        $content .= '<div class="status">'.$@.'</div>';
    }
    makeHtmlFormSafe(\$contents);
    $content .= '
        <div><b>awstats.'.$sitename.'.conf</b></div>
        <textarea name="awstats">'.$contents.'</textarea><br />
        <input type="submit" class="saveButton" value="Save" /> 
        </form>
    ';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_editSiteSave {
    my $state = shift;
    my $filename = $state->{cgi}->param("filename");
    if ($filename !~ m/\.conf$/ || $filename =~ m{/}) {
            sendResponse($state, "Stop dicking around!");
            return;
    }
    my $sitename = $filename;
    $sitename =~ s/^(.*)\.conf$/$1/;
    my $status = $sitename." saved.";
    eval { write_file($state->{config}->getWebguiRoot("/etc/".$filename), $state->{cgi}->param("webgui")) };
    if ($@) {
        $status = "Couldn't save $filename. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/".$sitename.".modproxy"), $state->{cgi}->param("modproxy")) };
    if ($@) {
        $status = "Couldn't save $sitename.modproxy. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/".$sitename.".modperl"), $state->{cgi}->param("modperl")) };
    if ($@) {
        $status = "Couldn't save $sitename.modperl. $@";
        carp $status;
    }
    eval { write_file($state->{config}->getRoot("/etc/awstats.".$sitename.".conf"), $state->{cgi}->param("awstats")) };
    if ($@) {
        $status = "Couldn't save awstats.$sitename.conf. $@";
        carp $status;
    }
    www_listSites($state, $status);
}

#-------------------------------------------------------------------
sub www_listServices {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("services");
    $content .= '<div class="status">'.$status.'</div>';
    $content .= '<table class="items">
    <tr>
        <td>Apache Modproxy</td>
        <td>';
    my $modproxy = WRE::Modproxy->new($state->{config});
    if ($modproxy->ping) {
        $content .= '
             <form action="/stopModproxy" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModproxy" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartModproxy" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Apache Modperl</td>
        <td>';
    my $modperl = WRE::Modperl->new($state->{config});
    if ($modperl->ping) {
        $content .= '
             <form action="/stopModperl" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startModperl" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartModperl" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>MySQL</td>
        <td>';
    my $mysql = WRE::Mysql->new($state->{config});
    if ($mysql->ping) {
        $content .= '
             <form action="/stopMysql" method="post">
                <input type="submit" value="Stop" />
             </form>';
    }
    else {
        $content .= '
             <form action="/startMysql" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartMysql" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>Spectre</td>
        <td>';
    my $spectre = WRE::Spectre->new($state->{config});
    if ($spectre->ping) {
            $content .= ' <form action="/stopSpectre" method="post">
                <input type="submit" value="Stop" />
             </form>';
    } 
    else {
             $content .= '<form action="/startSpectre" method="post">
                <input type="submit" value="Start" />
             </form>';
    }
    $content .= '
             <form action="/restartSpectre" method="post">
                <input type="submit" value="Restart" />
             </form>
         </td>
    </tr>
    <tr>
        <td>WRE Console</td>
        <td><form action="/stopConsole" method="post">
              <input type="submit" value="Stop" />
             </form>
        </td>
    </table>';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listSites {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("sites") . q|
             <form action="/addSite" method="post">
                <input type="submit" value="Add Site" />
             </form>
        <table class="items">|;
    $content .= '<div class="status">'.$status.'</div>';
    my $folder = dir($state->{config}->getWebguiRoot('/etc')) || carp "Couldn't open WebGUI configs folder.";
    while (my $file = $folder->next) {
        next if $file->is_dir;
        my $filename = $file->basename;
        next unless $filename =~ m/\.conf$/;
        next if $filename eq "spectre.conf";
        next if $filename eq "log.conf";
        my $sitename = $filename;
        $sitename =~ s/^(.*)\.conf$/$1/;
        $content .= qq|<tr><td>$sitename</td> <td>
             <form action="/editSite" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" value="Edit" />
             </form>
             <form action="/deleteSite" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" 
                    onclick="return confirm('Are you sure you wish to delete this site and all it\\\'s content and users?');"
                    class="deleteButton" value="Delete" />
             </form>
            </td></tr>|;
    }
    $content .= q|</table>|;
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listTemplates {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("templates");
    $content .= '<div class="status">'.$status.'</div>';
    $content .= q| <table class="items">|;
    my $folder = dir($state->{config}->getRoot("/var")) || carp "Couldn't open wre templates folder.";
    while (my $file = $folder->next) {
        next if $file->is_dir;
        my $filename = $file->basename;
        next unless $filename =~ m/\.template$/;
        $content .= qq|<tr><td>$filename</td> <td>
             <form action="/editTemplate" method="post">
                <input type="hidden" name="filename" value="$filename" />
                <input type="submit" value="Edit" />
             </form>
            </td></tr>|;
    }
    $content .= q|</table>|;
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_listUtilities {
    my $state = shift;
    my $status = shift;
    my $content = getNavigation("utilities");
    $content .= '<div class="status">'.$status.'</div>';
    sendResponse($state, $content);
}

#-------------------------------------------------------------------
sub www_restartModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl restarted.";
    unless ($service->restart) {
        $status = "Modperl did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy restarted.";
    unless ($service->restart) {
        $status = "Modproxy did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL restarted.";
    unless ($service->restart) {
        $status = "MySQL did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_restartSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre restarted.";
    unless ($service->restart) {
        $status = "Spectre did not restart successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_setup {
    my $state = shift;
    my $out = qq| <div id="tabsWrapper"> <div id="logo">WRE Console</div> <div id="navUnderline"></div> </div> |;
    my $config = $state->{config};
    my $cgi = $state->{cgi};
    my $file = WRE::File->new($config);

    # copy css into place
    $file->copy($config->getRoot("/var/setupfiles/wreconsole.css"),
        $config->getRoot("/var/wreconsole.css"));

    # deal with data form posted
    my $collectedJson = $cgi->param("collected");
    my $collected = JSON::jsonToObj($collectedJson);
    foreach my $key ($cgi->param) {
        next if $key eq "collected" || $key eq "step";
        $collected->{$key} = $cgi->param($key);
    }
    $collectedJson = JSON::objToJson($collected);

    # apache stuff
    if ($cgi->param("step") eq "apache") {
        my $apache = $config->get("apache");
        $out .= '<h1>Apache</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="mysql">
            <input type="hidden" name="collected" value=\''.$collectedJson.'\' />
            <p>
            mod_proxy Port <br />
            <input type="text" name="modproxyPort" value="'.($collected->{modproxyPort} || $apache->{modproxyPort}).'" />
            </p>
            <p>
            mod_perl Port <br />
            <input type="text" name="modperlPort" value="'.($collected->{modperlPort} || $apache->{modperlPort}).'" />
            </p>
            <input type="button" value="&laquo; Previous" onclick="this.form.step.value=\'\';this.form.submit()" />
            <input type="submit" value="Next &raquo;" />
            </form>
            ';
    }

    # mysql stuff
    elsif ($cgi->param("step") eq "mysql") {
        my $mysql = $config->get("mysql");
        $out .= '<h1>MySQL</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="webgui">
            <input type="hidden" name="collected" value=\''.$collectedJson.'\' />
            <p>
            Host <br />
            <input type="text" name="mysqlHost" value="'.($collected->{mysqlHost} || $mysql->{hostname}).'" />
            </p>
            <p>
            Port <br />
            <input type="text" name="mysqlPort" value="'.($collected->{mysqlPort} || $mysql->{port}).'" />
            </p>
            <p>
            Admin User <br />
            <input type="text" name="mysqlAdminUser" value="'.($collected->{mysqlAdminUser} || $mysql->{adminUser}).'" />
            </p>
            <p>
            Admin Password <br />
            <input type="text" name="mysqlAdminPassword" value="'.($collected->{mysqlAdminPassword} || "123qwe").'" />
            </p>
            <input type="button" value="&laquo; Previous"
            onclick="this.form.step.value=\'apache\';this.form.submit();" />
            <input type="submit" value="Next &raquo;" />
            </form>
            ';
    }

    # webgui stuff
    elsif ($cgi->param("step") eq "webgui") {
        $out .= '<h1>WebGUI</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="finish">
            <input type="hidden" name="collected" value=\''.$collectedJson.'\' />
            <p>
            What are the subnets WebGUI can expect Spectre to connect from? <br />
            <input type="text" name="spectreSubnets" value="'.($collected->{spectreSubnets} || findSubnet()).'" />
            <div class="subtext">If you do not know, then specify all of your IP addresses as a comma separated
            list like: 10.0.0.1/32,10.11.0.1/32,192.168.1.44/32
            </p>
            <input type="button" value="&laquo; Previous"
            onclick="this.form.step.value=\'mysql\';this.form.submit();" />
            <input type="submit" value="Next &raquo;" />
            </form>
            ';
    }

    # ready to install 
    elsif ($cgi->param("step") eq "finish") {
        $out .= '<h1>Ready To Install</h1>
            <p>The WRE is now ready to configure itself and install WebGUI.</p>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="install">
            <input type="hidden" name="collected" value=\''.$collectedJson.'\' />
            <input type="button" value="&laquo; Previous" class="deleteButton"
            onclick="this.form.step.value=\'webgui\';this.form.submit();" />
            <input type="submit" class="saveButton" value="Install &raquo;" />
            </form>
            ';
    }

    # ready to install 
    elsif ($cgi->param("step") eq "install") {
        my $crlf = "\015\012";
        my $socket = $state->{connection};
        
        # disable buffer caching
        select $socket;
        $| = 1; 

        # header
        $socket->send_basic_header; 
        print $socket "Content-Type: text/html$crlf";
        print $socket $crlf;
        print $socket "<h1>Configuring Your WRE Server</h1>$crlf";

        # config file
        print $socket "<p>Updating WRE config.</p>$crlf";
        $config->set("user", $collected->{wreUser});
        my $mysql = $config->get("mysql");
        $mysql->{adminUser} = $collected->{mysqlAdminUser};
        $mysql->{hostname}  = $collected->{mysqlHost};
        $mysql->{port}      = $collected->{mysqlPort};
        $config->set("mysql", $mysql);
        my $apache = $config->get("apache");
        $apache->{modperlPort}  = $collected->{modperlPort};
        $apache->{modproxyPort} = $collected->{modproxyPort};
        $config->set("apache", $apache);
        my $webgui = $config->get("webgui");
        my $spectreSubnetsString = $collected->{spectreSubnets};
        $spectreSubnetsString =~ s/\s+//g;
        my @spectreSubnets = split(",", $spectreSubnetsString);
        push(@spectreSubnets, "127.0.0.1/32");
        $webgui->{configOverrides}{spectreSubnets} = \@spectreSubnets;
        $config->set("webgui", $webgui);
        my $diff = "";

        # generate template vars
        my %var = (
            databasePort    => $collected->{mysqlPort}, 
            databaseHost    => $collected->{mysqlHost}, 
            modproxyPort    => $collected->{modproxyPort}, 
            modperlPort     => $collected->{modperlPort}, 
            );

        # mysql
        if ($collected->{mysqlHost} eq "localhost") {
            print $socket "<p>Configuring MySQL.</p>$crlf";
            $diff = $file->copy($config->getRoot("/var/setupfiles/my.cnf"),
                $config->getRoot("/etc/my.cnf"),
                { templateVars => \%var });
            if ($diff ne "1") {
                print $socket "<p>MySQL config file found that differs from the original. Please verify.
                    <br />$diff</p>";
            }
        }

        # apache
        print $socket "<p>Configuring Apache.</p>$crlf";

        # downloading webgui
        print $socket "<p>Downloading WebGUI.</p>$crlf";

        # extracting webgui
        print $socket "<p>Extracting WebGUI.</p>$crlf";

        # configuring webgui
        print $socket "<p>Configuring WebGUI.</p>$crlf";

        # status
        print $socket "<h1>Configuration Complete</h1><a href=\"/\">Click here to manage your WRE server.</a>$crlf";

        # done
        $socket->force_last_request;
        return;
    }

    # WRE
    else {
        $out .= '<h1>WRE</h1>
            <form action="/setup" method="post">
            <input type="hidden" name="step" value="apache">
            <input type="hidden" name="collected" value=\''.$collectedJson.'\' />
            <p>
            WRE Operating System User<br />
            <input type="text" name="wreUser" value="'.($collected->{wreUser} || $config->get("user")).'" />
            </p>
            <p>
            Do you want to configure this WRE as a development only environment?<br />
            <input type="radio" name="devOnly" value="1" />Yes &nbsp;
            <input type="radio" name="devOnly" value="0" checked="1" />No
            </p>
            <input type="submit" value="Next &raquo;" />
            </form>
            ';
    }
    sendResponse($state, $out);
}

#-------------------------------------------------------------------
sub www_startModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl started.";
    unless ($service->start) {
        $status = "Modperl did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy started.";
    unless ($service->start) {
        $status = "Modproxy did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL started.";
    unless ($service->start) {
        $status = "MySQL did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_startSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre started.";
    unless ($service->start) {
        $status = "Spectre did not start successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopConsole {
    my $state = shift;
    sendResponse($state, '<h1>WRE Console has shutdown.</h1>');
    exit;
}

#-------------------------------------------------------------------
sub www_stopModperl {
    my $state = shift;
    my $service = WRE::Modperl->new($state->{config});
    my $status = "Modperl stopped.";
    unless ($service->stop) {
        $status = "Modperl did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopModproxy {
    my $state = shift;
    my $service = WRE::Modproxy->new($state->{config});
    my $status = "Modproxy stopped.";
    unless ($service->stop) {
        $status = "Modproxy did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopMysql {
    my $state = shift;
    my $service = WRE::Mysql->new($state->{config});
    my $status = "MySQL stopped.";
    unless ($service->stop) {
        $status = "MySQL did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}

#-------------------------------------------------------------------
sub www_stopSpectre {
    my $state = shift;
    my $service = WRE::Spectre->new($state->{config});
    my $status = "Spectre stopped.";
    unless ($service->stop) {
        $status = "Spectre did not stop successfully. ".$@;
    }
    www_listServices($state, $status);
}


