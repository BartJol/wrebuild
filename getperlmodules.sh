#!/bin/bash

# This script will help you get all needed perlmodules
# listed in alphabetical order of file name
# Requires wget and gnu tar

mkdir -p source/perlmodules
cd source/perlmodules

# edit this to use your local cpan mirror http://www.cpan.org/SITES.html
#CPANMIRROR=http://search.cpan.org/CPAN
CPANMIRROR=http://archive.cs.uu.nl/mirror/CPAN

# http://search.cpan.org/dist/Algorithm-C3/
wget -t 4 -nv http://search.cpan.org/CPAN/authors/id/B/BL/BLBLACK/Algorithm-C3-0.07.tar.gz
tar zxf Algorithm-C3-0.07.tar.gz

# http://search.cpan.org/dist/Class-C3-XS/
wget -t 4 -nv http://search.cpan.org/CPAN/authors/id/B/BL/BLBLACK/Class-C3-XS-0.08.tar.gz
tar zxf Class-C3-XS-0.08.tar.gz

# http://search.cpan.org/dist/Class-C3/
wget -t 4 -nv http://search.cpan.org/CPAN/authors/id/F/FL/FLORA/Class-C3-0.20.tar.gz
tar zxf Class-C3-0.20.tar.gz

# http://search.cpan.org/dist/XML-TreePP/
wget -t 4 -nv http://search.cpan.org/CPAN/authors/id/K/KA/KAWASAKI/XML-TreePP-0.37.tar.gz
tar zxf XML-TreePP-0.37.tar.gz

# http://search.cpan.org/dist/XML-FeedPP/
wget -t 4 -nv http://search.cpan.org/CPAN/authors/id/K/KA/KAWASAKI/XML-FeedPP-0.37.tar.gz
tar zxf XML-FeedPP-0.37.tar.gz

# http://search.cpan.org/dist/Net_SSLeay.pm/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FL/FLORA/Net_SSLeay.pm-1.30.tar.gz
tar zxf Net_SSLeay.pm-1.30.tar.gz

# http://search.cpan.org/dist/Compress-Raw-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/Compress-Raw-Zlib-2.015.tar.gz
tar zxf Compress-Raw-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Base/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/IO-Compress-Base-2.015.tar.gz
tar zxf IO-Compress-Base-2.015.tar.gz

# http://search.cpan.org/dist/IO-Compress-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/IO-Compress-Zlib-2.015.tar.gz
tar zxf IO-Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Compress-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PM/PMQS/Compress-Zlib-2.015.tar.gz
tar zxf Compress-Zlib-2.015.tar.gz

# http://search.cpan.org/dist/Proc-ProcessTable/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DU/DURIST/Proc-ProcessTable-0.45.tar.gz
tar zxf Proc-ProcessTable-0.45.tar.gz

# http://search.cpan.org/dist/BSD-Resource/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JH/JHI/BSD-Resource-1.2902.tar.gz
tar zxf BSD-Resource-1.2902.tar.gz

# http://search.cpan.org/dist/URI/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/URI-1.37.tar.gz
tar zxf URI-1.37.tar.gz

# http://search.cpan.org/dist/IO-Zlib/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TO/TOMHUGHES/IO-Zlib-1.09.tar.gz
tar zxf IO-Zlib-1.09.tar.gz

# http://search.cpan.org/dist/HTML-Tagset/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz
tar zxf HTML-Tagset-3.20.tar.gz

# http://search.cpan.org/dist/HTML-Parser/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/HTML-Parser-3.60.tar.gz
tar zxf HTML-Parser-3.60.tar.gz

# http://search.cpan.org/dist/libwww-perl/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/libwww-perl-5.824.tar.gz
tar zxf libwww-perl-5.824.tar.gz

# http://search.cpan.org/dist/CGI.pm/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LD/LDS/CGI.pm-3.42.tar.gz
tar zxf CGI.pm-3.42.tar.gz

# http://search.cpan.org/dist/Digest-HMAC/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-HMAC-1.01.tar.gz
tar zxf Digest-HMAC-1.01.tar.gz

# http://search.cpan.org/dist/Digest-MD5/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-MD5-2.38.tar.gz
tar zxf Digest-MD5-2.38.tar.gz

# http://search.cpan.org/dist/Digest-SHA1/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/Digest-SHA1-2.11.tar.gz
tar zxf Digest-SHA1-2.11.tar.gz

# http://search.cpan.org/dist/Module-Build/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EW/EWILHELM/Module-Build-0.31012.tar.gz
tar zxf Module-Build-0.31012.tar.gz

# http://search.cpan.org/dist/Params-Validate/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Params-Validate-0.91.tar.gz
tar zxf Params-Validate-0.91.tar.gz

# http://search.cpan.org/dist/DateTime-Locale/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-Locale-0.42.tar.gz
tar zxf DateTime-Locale-0.42.tar.gz

# http://search.cpan.org/dist/Class-Singleton/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AB/ABW/Class-Singleton-1.4.tar.gz
tar zxf Class-Singleton-1.4.tar.gz

# http://search.cpan.org/dist/DateTime-TimeZone/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-TimeZone-0.84.tar.gz
tar zxf DateTime-TimeZone-0.84.tar.gz

# http://search.cpan.org/dist/Time-Local/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Time-Local-1.1901.tar.gz
tar zxf Time-Local-1.1901.tar.gz

# http://search.cpan.org/dist/Test-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHWERN/Test-Simple-0.86.tar.gz
tar zxf Test-Simple-0.86.tar.gz

# http://search.cpan.org/dist/Devel-Symdump/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AN/ANDK/Devel-Symdump-2.08.tar.gz
tar zxf Devel-Symdump-2.08.tar.gz

# http://search.cpan.org/dist/Pod-Escapes/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SB/SBURKE/Pod-Escapes-1.04.tar.gz
tar zxf Pod-Escapes-1.04.tar.gz

# http://search.cpan.org/dist/ExtUtils-CBuilder/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KW/KWILLIAMS/ExtUtils-CBuilder-0.24.tar.gz
tar zxf ExtUtils-CBuilder-0.24.tar.gz

# http://search.cpan.org/dist/Pod-Coverage/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCLAMP/Pod-Coverage-0.19.tar.gz
tar zxf Pod-Coverage-0.19.tar.gz

# http://search.cpan.org/dist/Pod-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AR/ARANDAL/Pod-Simple-3.07.tar.gz
tar zxf Pod-Simple-3.07.tar.gz

# http://search.cpan.org/dist/podlators/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RR/RRA/podlators-2.2.2.tar.gz
tar zxf podlators-2.2.2.tar.gz

# http://search.cpan.org/dist/DateTime/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-0.4501.tar.gz
tar zxf DateTime-0.4501.tar.gz

# http://search.cpan.org/dist/DateTime-Format-Strptime/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RI/RICKM/DateTime-Format-Strptime-1.0800.tgz
tar zxf DateTime-Format-Strptime-1.0800.tgz

# http://search.cpan.org/dist/HTML-Template/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SA/SAMTREGAR/HTML-Template-2.9.tar.gz
tar zxf HTML-Template-2.9.tar.gz

# http://search.cpan.org/dist/Crypt-SSLeay/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DL/DLAND/Crypt-SSLeay-0.57.tar.gz
tar zxf Crypt-SSLeay-0.57.tar.gz

# http://search.cpan.org/dist/String-Random/
wget -t 4 -nv $CPANMIRROR/authors/id/S/ST/STEVE/String-Random-0.22.tar.gz
tar zxf String-Random-0.22.tar.gz

# http://search.cpan.org/dist/Time-HiRes/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JH/JHI/Time-HiRes-1.9719.tar.gz
tar zxf Time-HiRes-1.9719.tar.gz

# http://search.cpan.org/dist/Text-Balanced/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DC/DCONWAY/Text-Balanced-v2.0.0.tar.gz
tar zxf Text-Balanced-v2.0.0.tar.gz

# http://search.cpan.org/dist/Tie-IxHash/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GS/GSAR/Tie-IxHash-1.21.tar.gz
tar zxf Tie-IxHash-1.21.tar.gz

# http://search.cpan.org/dist/Tie-CPHash/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CJ/CJM/Tie-CPHash-1.04.tar.gz
tar zxf Tie-CPHash-1.04.tar.gz

# http://search.cpan.org/dist/Error/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SH/SHLOMIF/Error-0.17015.tar.gz
tar zxf Error-0.17015.tar.gz

# http://search.cpan.org/dist/HTML-Highlight/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TR/TRIPIE/HTML-Highlight-0.20.tar.gz
tar zxf HTML-Highlight-0.20.tar.gz

# http://search.cpan.org/dist/HTML-TagFilter/
wget -t 4 -nv $CPANMIRROR/authors/id/W/WR/WROSS/HTML-TagFilter-1.03.tar.gz
tar zxf HTML-TagFilter-1.03.tar.gz

# http://search.cpan.org/dist/IO-String/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GA/GAAS/IO-String-1.08.tar.gz
tar zxf IO-String-1.08.tar.gz

# http://search.cpan.org/dist/Archive-Tar/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KANE/Archive-Tar-1.44.tar.gz
tar zxf Archive-Tar-1.44.tar.gz

# http://search.cpan.org/dist/Archive-Zip/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AD/ADAMK/Archive-Zip-1.26.tar.gz
tar zxf Archive-Zip-1.26.tar.gz

# http://search.cpan.org/dist/XML-NamespaceSupport/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RB/RBERJON/XML-NamespaceSupport-1.09.tar.gz
tar zxf XML-NamespaceSupport-1.09.tar.gz

# http://search.cpan.org/dist/XML-Parser/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSERGEANT/XML-Parser-2.36.tar.gz
tar zxf XML-Parser-2.36.tar.gz

# http://search.cpan.org/dist/XML-SAX/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRANTM/XML-SAX-0.96.tar.gz
tar zxf XML-SAX-0.96.tar.gz

# http://search.cpan.org/dist/XML-SAX-Expat/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BJ/BJOERN/XML-SAX-Expat-0.40.tar.gz
tar zxf XML-SAX-Expat-0.40.tar.gz

# http://search.cpan.org/dist/XML-Simple/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRANTM/XML-Simple-2.18.tar.gz
tar zxf XML-Simple-2.18.tar.gz

# http://search.cpan.org/dist/XML-RSSLite/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JP/JPIERCE/XML-RSSLite-0.11.tgz
tar zxf XML-RSSLite-0.11.tgz

# http://search.cpan.org/dist/SOAP-Lite/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MK/MKUTTER/SOAP-Lite-0.710.08.tar.gz
tar zxf SOAP-Lite-0.710.08.tar.gz

# http://search.cpan.org/dist/DBI/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TI/TIMB/DBI-1.607.tar.gz
tar zxf DBI-1.607.tar.gz

# http://search.cpan.org/dist/DBD-mysql/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CA/CAPTTOFU/DBD-mysql-4.010.tar.gz
tar zxf DBD-mysql-4.010.tar.gz

# http://search.cpan.org/dist/Convert-ASN1/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Convert-ASN1-0.22.tar.gz
tar zxf Convert-ASN1-0.22.tar.gz

# http://search.cpan.org/dist/HTML-TableExtract/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSISK/HTML-TableExtract-2.10.tar.gz
tar zxf HTML-TableExtract-2.10.tar.gz

# http://search.cpan.org/dist/Finance-Quote/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EC/ECOCODE/Finance-Quote-1.15.tar.gz
tar zxf Finance-Quote-1.15.tar.gz

# http://search.cpan.org/dist/JSON-XS/
wget -t 4 -nv $CPANMIRROR/authors/id/M/ML/MLEHMANN/JSON-XS-2.231.tar.gz
tar zxf JSON-XS-2.231.tar.gz

# http://search.cpan.org/dist/JSON/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MAKAMAKA/JSON-2.12.tar.gz
tar zxf JSON-2.12.tar.gz

# http://search.cpan.org/dist/version/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JP/JPEACOCK/version-0.76.tar.gz
tar zxf version-0.76.tar.gz

# http://search.cpan.org/dist/Path-Class/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KW/KWILLIAMS/Path-Class-0.16.tar.gz
tar zxf Path-Class-0.16.tar.gz

# http://search.cpan.org/dist/Config-JSON/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RI/RIZEN/Config-JSON-1.3.1.tar.gz
tar zxf Config-JSON-1.3.1.tar.gz

# http://search.cpan.org/dist/IO-Socket-SSL/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SU/SULLR/IO-Socket-SSL-1.22.tar.gz
tar zxf IO-Socket-SSL-1.22.tar.gz

# http://search.cpan.org/dist/Authen-SASL/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Authen-SASL-2.12.tar.gz
tar zxf Authen-SASL-2.12.tar.gz

# http://search.cpan.org/dist/perl-ldap/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/perl-ldap-0.39.tar.gz
tar zxf perl-ldap-0.39.tar.gz

# http://search.cpan.org/dist/Log-Log4perl/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHILLI/Log-Log4perl-1.20.tar.gz
tar zxf Log-Log4perl-1.20.tar.gz

# http://search.cpan.org/dist/POE/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-1.003.tar.gz
tar zxf POE-1.003.tar.gz

# http://search.cpan.org/dist/POE-Component-IKC/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GW/GWYN/POE-Component-IKC-0.2002.tar.gz
tar zxf POE-Component-IKC-0.2002.tar.gz

# http://search.cpan.org/dist/String-CRC32/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SO/SOENKE/String-CRC32-1.4.tar.gz
tar zxf String-CRC32-1.4.tar.gz

# http://search.cpan.org/dist/ExtUtils-XSBuilder/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GR/GRICHTER/ExtUtils-XSBuilder-0.28.tar.gz
tar zxf ExtUtils-XSBuilder-0.28.tar.gz

# http://search.cpan.org/dist/ExtUtils-MakeMaker/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MS/MSCHWERN/ExtUtils-MakeMaker-6.48.tar.gz
tar zxf ExtUtils-MakeMaker-6.48.tar.gz

# TODO trace to be replaced by: Devel::XRay http://search.cpan.org/dist/Devel-XRay/
wget -t 4 -nv http://backpan.perl.org/authors/id/J/JB/JBISBEE/trace-0.551.tar.gz
tar zxf trace-0.551.tar.gz

# http://search.cpan.org/dist/Clone/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RD/RDF/Clone-0.31.tar.gz
tar zxf Clone-0.31.tar.gz

# http://search.cpan.org/dist/Test-Pod/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PETDANCE/Test-Pod-1.26.tar.gz
tar zxf Test-Pod-1.26.tar.gz

# http://search.cpan.org/dist/Data-Structure-Util/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AN/ANDYA/Data-Structure-Util-0.15.tar.gz
tar zxf Data-Structure-Util-0.15.tar.gz

# http://search.cpan.org/dist/Parse-RecDescent/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DC/DCONWAY/Parse-RecDescent-1.96.0.tar.gz
tar zxf Parse-RecDescent-1.96.0.tar.gz

# http://search.cpan.org/dist/libapreq2/
wget -t 4 -nv $CPANMIRROR/authors/id/J/JO/JOESUF/libapreq2-2.08.tar.gz
tar zxf libapreq2-2.08.tar.gz

# http://search.cpan.org/dist/Net-Subnets/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SR/SRI/Net-Subnets-0.21.tar.gz
tar zxf Net-Subnets-0.21.tar.gz

# http://search.cpan.org/dist/MailTools/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MARKOV/MailTools-2.04.tar.gz
tar zxf MailTools-2.04.tar.gz

# http://search.cpan.org/dist/IO-stringy/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DS/DSKOLL/IO-stringy-2.110.tar.gz
tar zxf IO-stringy-2.110.tar.gz

# http://search.cpan.org/dist/MIME-tools/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DO/DONEILL/MIME-tools-5.427.tar.gz
tar zxf MIME-tools-5.427.tar.gz

# http://search.cpan.org/dist/HTML-Template-Expr/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SA/SAMTREGAR/HTML-Template-Expr-0.07.tar.gz
tar zxf HTML-Template-Expr-0.07.tar.gz

# http://search.cpan.org/dist/Template-Toolkit/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AB/ABW/Template-Toolkit-2.20.tar.gz
tar zxf Template-Toolkit-2.20.tar.gz

# http://search.cpan.org/dist/Scalar-List-Utils/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Scalar-List-Utils-1.19.tar.gz
tar zxf Scalar-List-Utils-1.19.tar.gz

# http://search.cpan.org/dist/Graphics-ColorNames/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RR/RRWO/Graphics-ColorNames-2.11.tar.gz
tar zxf Graphics-ColorNames-2.11.tar.gz

# http://search.cpan.org/dist/Module-Load/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KA/KANE/Module-Load-0.16.tar.gz
tar zxf Module-Load-0.16.tar.gz

# http://search.cpan.org/dist/Color-Calc/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CF/CFAERBER/Color-Calc-1.05.tar.gz
tar zxf Color-Calc-1.05.tar.gz

# http://search.cpan.org/dist/DateTime-Format-Mail/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/DateTime-Format-Mail-0.3001.tar.gz
tar zxf DateTime-Format-Mail-0.3001.tar.gz

# http://search.cpan.org/dist/Digest-BubbleBabble/
wget -t 4 -nv $CPANMIRROR/authors/id/B/BT/BTROTT/Digest-BubbleBabble-0.01.tar.gz
tar zxf Digest-BubbleBabble-0.01.tar.gz

# http://search.cpan.org/dist/Net-IP/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MANU/Net-IP-1.25.tar.gz
tar zxf Net-IP-1.25.tar.gz

# http://search.cpan.org/dist/Net-DNS/
wget -t 4 -nv $CPANMIRROR/authors/id/O/OL/OLAF/Net-DNS-0.65.tar.gz
tar zxf Net-DNS-0.65.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-DNS/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-DNS-1.02.tar.gz
tar zxf POE-Component-Client-DNS-1.02.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-Keepalive/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-Keepalive-0.25.tar.gz
tar zxf POE-Component-Client-Keepalive-0.25.tar.gz

# http://search.cpan.org/dist/POE-Component-Client-HTTP/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RC/RCAPUTO/POE-Component-Client-HTTP-0.87.tar.gz
tar zxf POE-Component-Client-HTTP-0.87.tar.gz

# http://search.cpan.org/dist/Test-Deep/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FD/FDALY/Test-Deep-0.103.tar.gz
tar zxf Test-Deep-0.103.tar.gz

# http://search.cpan.org/dist/Test-MockObject/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/Test-MockObject-1.09.tar.gz
tar zxf Test-MockObject-1.09.tar.gz

# http://search.cpan.org/dist/UNIVERSAL-isa/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/UNIVERSAL-isa-1.01.tar.gz
tar zxf UNIVERSAL-isa-1.01.tar.gz

# http://search.cpan.org/dist/UNIVERSAL-can/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CH/CHROMATIC/UNIVERSAL-can-1.12.tar.gz
tar zxf UNIVERSAL-can-1.12.tar.gz

# http://search.cpan.org/~evo/Class-MakeMethods-1.01/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EV/EVO/Class-MakeMethods-1.01.tar.gz
tar zxf Class-MakeMethods-1.01.tar.gz

# http://search.cpan.org/dist/Locale-US/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TB/TBONE/Locale-US-1.2.tar.gz
tar zxf Locale-US-1.2.tar.gz

# http://search.cpan.org/dist/Time-Format/
wget -t 4 -nv $CPANMIRROR/authors/id/R/RO/ROODE/Time-Format-1.09.tar.gz
tar zxf Time-Format-1.09.tar.gz

# http://search.cpan.org/dist/Weather-Com/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SC/SCHNUECK/Weather-Com-0.5.3.tar.gz
tar zxf Weather-Com-0.5.3.tar.gz

# http://search.cpan.org/dist/File-Slurp/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/File-Slurp-9999.13.tar.gz
tar zxf File-Slurp-9999.13.tar.gz

# http://search.cpan.org/dist/Text-CSV_XS/
wget -t 4 -nv $CPANMIRROR/authors/id/H/HM/HMBRAND/Text-CSV_XS-0.60.tgz
tar zxf Text-CSV_XS-0.60.tgz

# http://search.cpan.org/dist/File-Temp/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TJ/TJENNESS/File-Temp-0.21.tar.gz
tar zxf File-Temp-0.21.tar.gz

# http://search.cpan.org/dist/File-Path/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DL/DLAND/File-Path-2.07.tar.gz
tar zxf File-Path-2.07.tar.gz

# http://search.cpan.org/dist/File-Which/
wget -t 4 -nv $CPANMIRROR/authors/id/P/PE/PEREINAR/File-Which-0.05.tar.gz
tar zxf File-Which-0.05.tar.gz

# http://search.cpan.org/dist/Class-InsideOut/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DA/DAGOLDEN/Class-InsideOut-1.09.tar.gz
tar zxf Class-InsideOut-1.09.tar.gz

# http://search.cpan.org/dist/HTML-TagCloud/
wget -t 4 -nv $CPANMIRROR/authors/id/L/LB/LBROCARD/HTML-TagCloud-0.34.tar.gz
tar zxf HTML-TagCloud-0.34.tar.gz

# http://search.cpan.org/dist/Set-Infinite/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/Set-Infinite-0.63.tar.gz
tar zxf Set-Infinite-0.63.tar.gz

# http://search.cpan.org/dist/DateTime-Set/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Set-0.26.tar.gz
tar zxf DateTime-Set-0.26.tar.gz

# http://search.cpan.org/dist/DateTime-Event-Recurrence/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Event-Recurrence-0.16.tar.gz
tar zxf DateTime-Event-Recurrence-0.16.tar.gz

# http://search.cpan.org/dist/DateTime-Event-ICal/
wget -t 4 -nv $CPANMIRROR/authors/id/F/FG/FGLOCK/DateTime-Event-ICal-0.09.tar.gz
tar zxf DateTime-Event-ICal-0.09.tar.gz

# http://search.cpan.org/dist/MIME-Types/
wget -t 4 -nv $CPANMIRROR/authors/id/M/MA/MARKOV/MIME-Types-1.27.tar.gz
tar zxf MIME-Types-1.27.tar.gz

# http://search.cpan.org/dist/File-MMagic/
wget -t 4 -nv $CPANMIRROR/authors/id/K/KN/KNOK/File-MMagic-1.27.tar.gz
tar zxf File-MMagic-1.27.tar.gz

# http://search.cpan.org/dist/PathTools/
wget -t 4 -nv $CPANMIRROR/authors/id/S/SM/SMUELLER/PathTools-3.29.tar.gz
tar zxf PathTools-3.29.tar.gz

# http://search.cpan.org/dist/Module-Find/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CR/CRENZ/Module-Find-0.06.tar.gz
tar zxf Module-Find-0.06.tar.gz

# http://search.cpan.org/dist/Archive-Any/
wget -t 4 -nv $CPANMIRROR/authors/id/C/CM/CMOORE/Archive-Any-0.0932.tar.gz
tar zxf Archive-Any-0.0932.tar.gz

# http://search.cpan.org/dist/Image-ExifTool/
wget -t 4 -nv $CPANMIRROR/authors/id/E/EX/EXIFTOOL/Image-ExifTool-7.67.tar.gz
tar zxf Image-ExifTool-7.67.tar.gz

# http://search.cpan.org/dist/Text-Aspell/
wget -t 4 -nv $CPANMIRROR/authors/id/H/HA/HANK/Text-Aspell-0.09.tar.gz
tar zxf Text-Aspell-0.09.tar.gz

# http://search.cpan.org/dist/MySQL-Diff/
wget -t 4 -nv $CPANMIRROR/authors/id/A/AS/ASPIERS/MySQL-Diff-0.33.tar.gz
tar zxf MySQL-Diff-0.33.tar.gz

# http://search.cpan.org/dist/List-MoreUtils/
wget -t 4 -nv $CPANMIRROR/authors/id/V/VP/VPARSEVAL/List-MoreUtils-0.22.tar.gz
tar zxf List-MoreUtils-0.22.tar.gz

# http://search.cpan.org/dist/Scalar-List-Utils/
wget -t 4 -nv $CPANMIRROR/authors/id/G/GB/GBARR/Scalar-List-Utils-1.19.tar.gz
tar zxf Scalar-List-Utils-1.19.tar.gz

# http://search.cpan.org/dist/Devel-StackTrace/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Devel-StackTrace-1.20.tar.gz
tar zxf Devel-StackTrace-1.20.tar.gz

# http://search.cpan.org/dist/Class-Data-Inheritable/
wget -t 4 -nv $CPANMIRROR/authors/id/T/TM/TMTM/Class-Data-Inheritable-0.08.tar.gz
tar zxf Class-Data-Inheritable-0.08.tar.gz

# http://search.cpan.org/dist/Exception-Class/
wget -t 4 -nv $CPANMIRROR/authors/id/D/DR/DROLSKY/Exception-Class-1.26.tar.gz
tar zxf Exception-Class-1.26.tar.gz