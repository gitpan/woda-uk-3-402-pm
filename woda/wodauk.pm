#!/usr/local/bin/perl
# no strict;	# uncomment this line if running under mod_perl, also see below for mod_perl

#
#     WODA - Web Oriented Database
#
# A program and library of perl functions to manage semi-relational database
# using WWW and cgi interface. Includes functions to add, edit, browse and
# search records using WWW. Database structure is described in a separate
# file.
#
# Usage:
#	see http://itc.fgg.uni-lj.si/woda/
#
# Test:
#	if executed it should print out nothing ... but this should:
#
#	#!/usr/local/bin/perl
#	require woda-uk.pl;	#or wodauk.pm ... whatever this is
#	do WODA'run();
#
# Author:
#	Ziga Turk (zturk@fagg.uni-lj.si)
#
# Copyright:
#	Copyright (c) 1995-99 Ziga Turk,
#	University of Ljubljana, Faculty of Civil Engineering and Geodesy, IKPIR.
#	All rights reserved.
#
#	This program is free software; you can redistribute it and/or
#	modify it under the same terms as Perl itself.
#
#	GPL and Artistic licenses apply. See licence.txt
#	http://itc.fgg.uni-lj.si/woda/licence.txt
#
#	This also applies:
#	You MAY NOT set up this database in such a way that the reference to
#	WODA origin or the "powered by WODA icon" is obscured in any way.
#
# Installation:
#	read man.htm
#	find string 'sub mainConfig' in this file and configure
#	access to web server's error log helps!
#
# Disclaimer:
#	This software is supplied as is, without any warranties.
#	Use at your own risk.
#
# Release notes:
#	See http://itc.fgg.uni-lj.si/woda/release.htm
#
#########################################################################

$errors = <<EOM;
Also, in the configuration phase, $TESTCGIURL does not get set.  $TESTCGIDIR
is set properly (2 places), but the url portion is left at the default value
of /cgi/test.
EOM

# In 3.402
# - add diagnostics with all evals ... maybe eval in a subroutine ?
# - LoginForm takes parameters

# In 3.401
# + BUG: Admin does not see EDIT buttons
# + compensation of a Perl bug in wbTab2Rec

# In 3.400
# + WODA looks for SENDMAIL at a few other places but the one specified
# + SearchAgain (experimental)
# + Go has a search as parameter as well
# + less help/more help ... do so that cookies are set ... then Location: reloads the calling page
# + login/logout ... without additional window
# + much more powerfull record formatting options:
#   format;DEFAULT can be replaced by three settings:
#   formatHeadDEFAULT,formatRowDEFAULT and formatFootDEFAULT
#   format;USER* are obsolete
# + new toolbar, toolbarText and pageEnd settings
#   allow for full control of the end of the pages
#   WBB{searchReformat}=groups to allow reformat of search results

# - .tbl ... get rid of \r !!!
# - format supplied on URL ... should not include Perl code !
# - counting of subcategories (counts first subcat as itself)
# - Browse ring ... on all URLs
# - enable reformat as frame
# - disable built in formats
# - 'admin' name should be configurable
# - JavaScript search
# ? Editing of records does not retain other input that is not "modified/seen" by a given user... 
# - page number on top of search results
# - WBF{$x,cell} cell parameter for the field
# - : ... :: escape when used as delimiter in hierarchies
# - wbb{toolbar}
#	pagePattern text
#	pagePattern text
# - is it an error for owner to change the ownership of the record?
# - allow composing browse AZ on the fly ? slow !
# - check if &FETCH works, existance of directories under DOS ???
# - $WBB{toolbar} like Search<tab>item to add in all /search/ pages
# - up.gif is 21x23 and not 23x21
# - get rid of any PLAINTEXT
# ? check patterns that get passed on to external grep
# - remember search expressions
# - gather all simple search patterns, match printouts with them and <B> </B> found words
#   not within TAGS
# known issues:
# - if application is password protected, Explorer asks for a password
#   again, when new windows are being opened
# - Explorer does not open new windows quite in the same way as netscape

##############################################################################################
# compatibility with definitions that used
# unpackaged WODA and do main() ... new way is marked below

sub main {
 
	do WODAUK'mainError() if $ENV{MOD_PERL};

	if (defined &WODAUK'run) {		#UK
	  if (defined %WBB) { 
	    do WODAUK'run(*WBB,*WBF);		#UK
	  } else {
	    do WODAUK'run(*WBBase,*WBField); 	#UK
	  }
	} else {
	  if (defined %WBB) { 
	    do run(*WBB,*WBF);
	  } else {
	    do run(*WBBase,*WBField);
	  }
	}
}

# to use WODA as a package under MOD_PERL
# uncomment the package line below
# beware that this makes life quite complicated for
# any user defined functions !
#
# package WODAUK;	#UK

	$VERSION = '3.402';

#
# all server-wide configuration parameters are in this sub
# Config section (applies to all wb databases at your host)
#

sub mainConfig {

	# uncomment this to ease the debuggiung ... all errors will go to a file
	# this should reduce "Server error" messages on most httpd servers
	#
	# open (STDERR,">>./_cache/stderr.txt");
			
	# who is admin group (pick one of the two options)

#	$ADMUSER = 'admin 193.2.92.14';	# who is admin group - anyone who comes from this IP 
	$ADMUSER='admin ##### zebra';	# !!! CONFIG !!! anyone who knows password zebra
					# *or* comes from host which has ##### in it's name (none!) 

	# UNIX or not

	if (-s "/bin/ln" ) {			

	    # a nice unix machine 

	    $UNIX=1;

	    umask (0);				# change if you need fancy protections
	    $TMPDIR = "/tmp";			# required ... you ISP may not let you use this 
            $DIRMODE=0777;			# default directory mode
	    $CHMOD = 'chmod';			# required
	    $MV = "mv -f";			# can live without
	    $SENDMAIL = '/usr/lib/sendmail';				# needed for Angie's search subscriptions
	    $DUMPABLEPERL = '/users/zturk/undump-1.1/perl.v4';		# needed to compile Perl (can do without)
	    $UNDUMP = '/users/zturk/undump-1.1/undump';			# needed to compile Perl (can do without)
	    $CRONTAB = 'crontab';
	    $AT = 'at';
	    $GREP = 'grep';			# can live without, but in this case,
						# comment it out!

	    # if you intend to use &FETCH() 
	    # it will fail if this is not set correctly
	    # these values are defined in your perl's socket.ph
	    # using socket ph would slow things down ... so go, copy it

	    $SOCK_STREAM = 1;
	    $AF_INET = 2;

	    # in the following CGI direcory the WWW user (guest or nobody)
	    # should have read,write and execute permissions
	    # here will the generator save test database definitions and the
	    # compiler the compiled versions
	    # direcory and corresponnding URL are required

	    $TESTCGIDIR='/usr/local/www/cgi/test';
	    $TESTCGIURL='/cgi/test';

	} else {

	    # this is not UNIX machine:

	    $UNIX=0;

	    # where is perl.exe. In many cases, woda can figure it out so keep it commented

	    #$PERL='C:\perl\perl.exe';

	    # on which hard drive will be woda and the databases
	    # this is only to prevent AdmStatus from reporting
	    # non existing directories when in fact they all exist
	    # looks like WINDOS perl find -d "D:/usr/local"
	    # but failes with -d "/usr/local" although it can chdir to it! 

	    $DISK='D:';	

	    # settings for win32 box
	    # WODA works very well with Omni, Xitami or Apache
	    # WODA and IIS ... should be possile, but you are asking for trouble
	    # and the problem is not in WODA! 

	    $NO_CRYPT = 1;		# Perl does not have crypt function
	    $NO_TIMES = 1;		# Perl does not have times function
	    $NO_DIRTIMES = 1;		# modification time is not known for directories
	    $TMPDIR = 'C:/windows/temp';

	    # you could comment this line out on most Win HTTPD servers
	    # I was told PWS-HTTPD and perhaps IIS servers like this as first line of the header
	    # some servers, such as Apache for Windows, hate it!
	    #
	    # $HTTP200OK = "HTTP/1.0 200 OK\n";	
	
	    # feel free to add any of the settings from UNIX
	    # if you know what you are doing

	    $SOCK_STREAM = 1;
	    $AF_INET = 2;

	    # in the following CGI direcory the WWW user (guest or nobody)
	    # should have read,write and execute permissions
	    # here will the generator save test database definitions and the
	    # compiler the compiled versions
	    # direcory and corresponnding URL are required

	    $TESTCGIDIR='/usr/local/www/cgi/test';
	    $TESTCGIURL='/cgi/test';
	}

	$FILETYPES = 'doc|xls|pdf|rtf|txt|ppt|zip';
	# for these extentions .gif exists at ICONURL e.g. doc.gif is there
}

############# No need to change anything below ##################

# lets mention some global functions so that the program that
# creates the split version will include them in the base file
# globals:  &NOOP() &ID() &TODAY() &QRY() &ROWS() &FLD() &KEY() &FETCH() &PIC()
#################################################################

sub run {

	# reset all variables for the sake of modPerl

	if ($ENV{MOD_PERL}) {
	    do mainClean();
	    $MOD_PERL = 1;
	}

	# make PATH_INFO of the IIS compatible with the rest

	if ($ENV{PATH_INFO}) {
	    local ($pi,$sn) = ( $ENV{PATH_INFO} , $ENV{SCRIPT_NAME} );
	    if ($pi =~ m/^$sn/) {
		$ENV{PATH_INFO} = $';
	    }
	}

	# compatibility with old versions of data definition file

	local (*WBB,*WBF) = @_;
	     
	# where is this script

	do wbWhoami();

	do mainConfig();

	($CALLER_PACKAGE,@x) = caller;
	do findMYSubs();
#########
	# some pointers to home

	$WBHome='http://itc.fgg.uni-lj.si/woda';
	$WBHelp='http://itc.fgg.uni-lj.si/woda/help.htm';

	# defaults and compatibility issues

	$WBB{'iconURL'} = "/woda/icons" unless $WBB{'iconURL'};
	$WBB{'sort;DEFAULT'} = $WBB{'listRow'} unless $WBB{'sort;DEFAULT'};
	$WBB{'format;DEFAULT'} = $WBB{'listHtml'} unless $WBB{'format;DEFAULT'};
	$WBB{'formatNameDEFAULT'} = 'Default' unless $WBB{'formatNameDEFAULT'} ne '';
	if ($WBB{formatRowDEFAULT} eq '' && $WBB{"format;DEFAULT"} ne '') {
	    $WBB{formatHeadDEFAULT}="<OL>";
	    $WBB{formatFootDEFAULT}="</OL>";
 	}
	$WBB{'maxHits'} = 10000 unless $WBB{'maxHits'};
	$WBB{'dfltHits'} = 20 unless $WBB{'dfltHits'};
	$WBB{'generatedHomePage'} = "index.htm" if $WBB{'homePage'} eq '1';
	$WBB{'homePage'} = "index.htm" if $WBB{'homePage'} eq '1';
	$WBB{'groups'} = $WBB{'groups'} || $WBB{'users'};
	# $WBB{'agentGroups'} = $WBB{'agentGroups'} || $WBB{'agentUsers'};
	$ICONPAR = 'BORDER=0 HEIGHT=21 WIDTH=23';
	$ICONURL = $WBB{'iconURL'};
	$ICONOPEN = $WBB{'iconOpen'} || 'open';
 	$BIGICONPAR = 'BORDER=0 HEIGHT=42 WIDTH=46';
        $TOOLBAR1 = "<TD ALIGN=CENTER CLASS=TOOLBAR>";
        $TOOLBAR2 = "</TD>";

	$nCriteria = 5;

	$INPUTON="<FONT FACE=\"Courier,Courier New\">";
	$INPUTOFF="</FONT>";

	# internationalisation

	$WBB{'intlCharset'} = $WBB{intlCharset} || 'ISO-8859-1'; 		#UK
	$WBB{'intlCollate'} = '' || $WBB{intlCollate};				#UK
	$WBB{'intlLower'} = '' || $WBB{intlLower};				#UK
	$WBB{'intlAscii'} = '' || $WBB{intlAscii};				#UK
	$WBlanguage = 'UK';  							#UK
	$WBlanguageAuthor = 'Ziga Turk &lt;ziga.turk@fagg.uni-lj.si&gt;';	#UK

	# warn about global subroutines if we are a WODA package

	if ($#MYSubs > 0 && defined &WODA'run) {	# one is main!
	    do wbFail ("Subroutines are not allowed in package $CALLER_PACKAGE",
		"Author of this database should re-write the
		 routines into a separate package. Any WODA variables should be
		 prefixed with WODA' eg. $WODA'rec{name}.");
	}

	# random seed

	time =~ m/....$/;
	srand ($&*$$);

	# make directories

	if ($WBB{dataDir}) {
	    unless (-d $WBB{dataDir}) { mkdir ($WBB{dataDir},$DIRMODE); }
	    unless (chdir $WBB{dataDir}) { do wbFail("Cannot create and chdir to dataDir=$WBB{dataDir}"); }
	
	    unless (-d '_cache') { mkdir ('_cache',$DIRMODE); }
	    unless (-d '_cache') { do wbFail("Cannot create and chdir to $WBB{dataDir}/_cache directory"); }
	}

	# --- should we run from command line ?

	do mainCmdline();
	do mainPathInfo();

	# --- JavaScript compatibility

	$JS=0;

	if ($ENV{HTTP_USER_AGENT} =~ m/Mozilla\/4/) {
	   $JS=1.2;
	}

	if ($ENV{HTTP_USER_AGENT} =~ m/Mozilla\/3|Mozilla\/2/) {
	   $JS=1.0;
	}

	if ($WBB{JavaScript} ne '') {
	    $JS = $WBB{JavaScript} if $WBB{JavaScript} < $JS;
	}

	# fill %CGI with parameters

	$* = 1;
	do htParseMulti();
	$* = 0;

	do htReadCookies();

	if ($CGI{_isindex} && !$Page) {
	    $Page = "Show";
	    $CGI{_id} = $CGI{_isindex};
	}

	if (!$Page) {
	    $Page = "Home";
        }

	if ($CGI{_isindex} && !$Page) {
	    $Page = "Show";
	    $CGI{_id} = $CGI{_isindex};
	}

	$Action = "cgi" . $Page;
	$MyAction = "my" . $Page;

	############ SECURITY ############

	if ($COOKIE{'_user'} ne '') {
	    ($CookieGroup,$CookiePass)=split (/:/,$COOKIE{'_user'},2);
	}
	do wbSetGroup();

	### can group do the action (admin can do anything!)

	if (&wbDenied($Group,$Page)) {
	    do printDeny();
	}

	########### ARE WE CLOSED #####

	if (-e "_cache/closed.ip") {
	    open (H,"_cache/closed.ip");
	    $tip = <H>;
	    close (H);
	    if ($tip ne $ENV{REMOTE_ADDR}) {
	        open (H,"_cache/closed.txt");
	        @msg = <H>;
		$msg = join('',@msg);
	        close (H);
		do wbError("Database is closed","$msg");
	    } else {
		$WBB{dbTitle} .= " <BLINK>[CLOSED FOR GENERAL PUBLIC]</BLINK>";
	    }
	}

	########### CACHEING ##########

	$NOCACHE = '.|/Adm|Form';	# do not cache anything !!!

	$request = "_$ENV{PATH_INFO}_$ENV{QUERY_STRING}_";
	$request =~ s|/|\.|g;

	unless ($request =~ m|$NOCACHE| 
	        || admin =~ m|$groups|
	        || $ENV{'REQUEST_METHOD'} eq "POST" ) {	# something is not cached
	    $file = "$WBB{dataDir}/_cache/$request";
	    if (-s $file) {
		open (h,$file);
		@x = <h>;
		close h;
	    } else {
		open (STDOUT,">$file");
		do mainAction();
		close (STDOUT);	

		open (STDOUT,">-");
		open (h,$file);
		@x = <h>;
		close h;
	    }
	    print @x;
	} else {
	    do mainAction();
	}

	do wodaExit();
}

sub mainError {

	do wbFail ("Improper use of WODA.","The database definition file
should end in a call like <I>do main(*WBB,*WBF)</I> or <I>do WODAUK'run(*WBB,*WBF)</I>
if used under MOD_PERL.
");
}

sub mainClean {

	%_WBB=%WBB;
	%_WBF=%WBF;
	$_v = $VERSION;

	undef %CGI;
	undef %COOKIE;
	undef %C_TYPE;
	undef %EXT;
	undef %FieldType;
	undef %GI;
	undef %Hidden;
	undef %IDCache;
	undef %IsField;
	undef %MetaB;
	undef %MetaF;
	undef %Rec;
	undef %TBL;
	undef %VALrec;
	undef %WBB;
	undef %WBF;
	undef %WbBase;
	undef %WbField;
	undef %XENV;
	undef %_main;
	undef %agentCGI;
	undef %agentRec;
	undef %count;
	undef %data;
	undef %entry;
	undef %err;
	undef %hdr;
	undef %hits;
	undef %oldRec;
	undef %pic;
	undef %print;
	undef %r;
	undef %rec;
	undef %saveHidden;
	undef %savedRec;
	undef %seen;
	undef %sort;
	undef %tr;
	undef %treeCount;
	undef %treeID;
	undef %treeMain;
	undef %valRec;
	undef %words;
	undef %x;
	undef %xRec;
	undef %xrec;
	undef @Fields;
	undef @MetaB;
	undef @MetaF;
	undef @PFields;
	undef @a;
	undef @aWords;
	undef @acts;
	undef @ads;
#	undef @agentGroups;
	undef @agentRequests;
	undef @all;
	undef @allRec;
	undef @altTexts;
	undef @ap;
	undef @az;
	undef @bak;
	undef @butts;
	undef @c;
	undef @cats;
	undef @colWords;
	undef @cron;
	undef @csv;
	undef @data;
	undef @days;
	undef @daysVal;
	undef @def;
	undef @del;
	undef @err;
	undef @fieldNames;
	undef @fields;
	undef @files;
	undef @first;
	undef @flds;
	undef @formats;
	undef @frames;
	undef @headers;
	undef @helps;
	undef @icons;
	undef @id;
	undef @ids;
	undef @indexes;
	undef @items;
	undef @jobs;
	undef @key;
	undef @kwords;
	undef @l;
	undef @letters;
	undef @lines;
	undef @links;
	undef @list;
	undef @nWords;
	undef @niceFields;
	undef @optionText;
	undef @options;
	undef @opts;
	undef @p;
	undef @pairs;
	undef @passwd;
	undef @prompts;
	undef @rec;
	undef @recFiles;
	undef @records;
	undef @reqs;
	undef @rowWords;
	undef @rows;
	undef @sWords;
	undef @savePF;
	undef @sortedWords;
	undef @stopWords;
	undef @stuff;
	undef @subs;
	undef @t;
	undef @texts;
	undef @tmp;
	undef @to;
	undef @types;
	undef @ua;
	undef @ub;
	undef @uf;
	undef @uo;
	undef @v;
	undef @val;
	undef @vals;
	undef @var;
	undef @vars;
	undef @w;
	undef @wbp;
	undef @week;
	undef @words;
	undef @x;
	undef @x_keys;
	undef @x_vals;
	undef @xx;
	undef @y;

	# reset any variable to undefined value

	reset 'a-z';
	reset 'A-Z';

	# restore the values defined in the data definition

	%WBB=%_WBB;
	%WBF=%_WBF;
	$VERSION = $_v;
}

sub findMYSubs {
# sets @MYSubs
	undef @MYSubs;
	local(*stab) = eval("*_$CALLER_PACKAGE") if $PERLV <5;
        local(*stab) = eval("*${package}::") if $PERLV>=5;

	while (($key,$val) = each(%stab)) {
           local(*entry) = $val;
           if (defined &entry) {
		push (@MYSubs,$key);
           }
	}
}

sub wodaExit {

	if ($MODPERL) {
	    do Apache'exit(0);
	} else {
	    exit(0);
	}
}

# sets the global Group variable
# uses the global URLGroup variable

sub wbSetGroup {

	# command line group is admin by default !

	if ($CMDLINE && $CookieGroup eq 'admin') {
  	    $Group = 'admin';
	    return;
	}

	# web group is guest by defualt

	$Group = 'guest';
	$User = 'anonymous';
	#undef $User;

	$rh = $ENV{'REMOTE_HOST'};
	$ra = $ENV{'REMOTE_ADDR'};

	if ($WBB{'groups'} eq '') {	# no host can have name like '..'
	    @passwd = $ADMUSER;
	} else {
	    @passwd = split (/\n/,$WBB{groups});
	}

	# set Group based on IP

	foreach $_ (@passwd) {
	    ($group,$patt,$passwd)=split(/\s+/,$_,3);
	    $patt =~ s/\s+//;
	    if (($rh && $rh =~ m/$patt/) || $ra=~ m/$patt/) {
	        $Group=$group;
	        last;
	    }
	}

	# scope of login cookines

	$cscope = $WBB{userScope} || $ENV{SCRIPT_NAME};
	$cu=$cv=$cg='';

	# cookies override URL if URL is non empty

	if ($CookieGroup ne '' && $URLGroup eq '') {

	    # using username and password from cookies
	    # nothing on URL

	    $Log .= "Using cookies to log as '$CookieGroup'\n";

	    $URLGroup = $CookieGroup;
	    $URLPass = $CookiePass;

	} else {

	    # not using username and password from cookies
	    # but from URL
	    # reset all cookies

	    $Log .= "Using URL to log as '$URLGroup'\n";

	    $cu = &htFormatCookie('_user'   ,"a",$cscope,"RESET") if $COOKIE{_user};
	    $cg = &htFormatCookie('_group'  ,"a",$cscope,"RESET") if $COOKIE{_group};
	    $cv = &htFormatCookie('_voucher',"a",$cscope,"RESET") if $COOKIE{_voucher};
	}

	# can the user identify through userTable ?

	if ($WBB{userTable} && $URLGroup !~ /^admin$|^guest$|^$/) { # guest,admin, empty
	    $t = int(time/1000);

	    # did he supply a good voucher
	    if ($COOKIE{_group} && $COOKIE{_voucher} && &wbTestPass("$ra$t:$URLGroup",$COOKIE{_voucher})   ) {
		 $Group = $COOKIE{_group};
		 $User = $URLGroup;
		 $Log .= "Logged using valid voucher\n";
		 return;
	    }

	    # no, test him te slow way
	    $dataDir = &wbTables('DIR',$WBB{userTable});
	    unless (-d $dataDir) {
		do wbFail ("Directory for table $WBB{userTable} not found\n");
	    }

	    if (-f "$dataDir/$URLGroup.rec") {
	      do wbParseFile("$dataDir/$URLGroup.rec",1);
	      if ($rec{_password} && &wbTestPass($URLPass,$rec{_password})) {
		$User = $URLGroup;
		$Group = $rec{group} || $WBB{userTableGroup} || 'user';

		$ugroup = "$Group";
		$voucher = &wbCryptPasswd("$ra$t:$User");

	        $cu = &htFormatCookie('_user',"$URLGroup:$URLPass",$cscope,'SESSION');
		$cg = &htFormatCookie('_group',$ugroup,$cscope,'SESSION');
		$cv = &htFormatCookie('_voucher',$voucher,$cscope,'SESSION');

		if ($WBB{userAllow}) {
		    $userAllowFailed = 1 unless eval ($WBB{userAllow});
		}

		$Log .= "Verifed username and password in a database, setting voucher\n";
		&htDemandCookie($cu,$cg,$cv);
		return;

              }
	      $Log .= "Login in userTable failed - bad password\n";
	      undef %rec;
	    } else {
	      $Log .= "Login in userTable failed - bad username\n";
	    }
	}

	# we are doing it with groupname/password only ... reset group and voucher

	$cg = &htFormatCookie('_group'  ,"a",$cscope,"RESET") if $COOKIE{_group};
	$cv = &htFormatCookie('_voucher',"a",$cscope,"RESET") if $COOKIE{_voucher};
	&htDemandCookie($cu,$cg,$cv);

	# can we override the groupname derived from server authentification or IP assignement ?

	if ($URLGroup) {
	    if ($Group eq 'admin') {
	        $Group = $URLGroup;	# someone who is cleared as admin becomes anyone else
	        $Log .= "You could be admin, so you can be $URLGroup\n";
	    } else {
		@x = grep(/^$URLGroup\s/,@passwd);
	        ($group,$patt,$passwd)=split(/\s+/,$x[0],3);
		if ($group && $passwd && $passwd eq $URLPass) {
		    $Group = $group;
	            $Log .= "Logged because groups matched\n";
		}
	    }
	} else {	# admin required on URL
	    $Group = 'guest' if $Group eq 'admin';
	    $Log .= "Logged as guest by default\n";
	}

}

sub cgiResetCookie {

	$name = $CGI{cookie};
	$cookie = &htFormatCookie($name,"b",$ENV{SCRIPT_NAME},"RESET");

	do printLocation($CGI{referer},$cookie);
}

sub wbWhoami {

        local ($package,$filename,$line) = caller;
	local ($i,$c);
	$filename =~ m|[^/]*$|;
	$WBPath = $`;			# in which dir is this script
	chop ($WBPath);			# remove the trailing /
	$WBFile = $&;			# what is the name of this script
	$WBFile =~ m/(..)\.p.$/;	# langauage before dot.p	
	$WBLang = $1;			# what is the language code
	$WBLib = "$WBPath/$WBLang";	#
	$WBProg = $0;			# command being executed
	$WBProg =~ m|(.*)/[^/]$|;	#

	$PERL = $PERL || $^X;		# first argument from command line
	if ($PERL !~ /perl/i || $WBProg =~ m/$PERL/ || $PERL eq 'perl') {	# looks like $^X reported wrong
	    $PERL = '/usr/local/bin/perl';
	    $PERL = '/usr/bin/perl' unless -e $PERL;
	    $PERL = '' unless -e $PERL;
	}
	$PERLV = $] + 0.0;		# what Perl are we runing
}

sub wbDeniedURL {

	local ($dgroup,$durl)=@_;
	local ($x1,$x2);

	($x1,$x2)=split(/\?/,$durl,2);
	$x1 =~ m|/([^/]*)$|;
	$durl = $1;

	return &wbDenied($dgroup,$durl);
}

sub wbDenied {

	local ($dgroup,$dpage)=@_;
	local (@x);
		
	if ($userAllowFailed) {
	    return 0 unless $dpage =~ /^Login$|^LoginForm$|^$|^About$/;
	}

	# deny access of others to the record
	if ($RGroup eq 'other' && $dpage =~ m/Edit|Modify|Delete/ && $Group ne 'admin') {
	    return 1;
	}

	# Agent and Adm URLs are denied by default

	@x = split (/\n/,$WBB{rights});
	push (@x,"deny  .*	^Agent");
	push (@x,"deny	.*	^Adm");

	foreach $_ (@x) {
	    ($what,$group,$patt)=split(/\s+/,$_,3);
	    $patt =~ s/\s+//;
	    if ($dpage =~ m/$patt/ && $Group=~ m/$group/ ) {
		return 1 if $what eq 'deny' && $Group ne 'admin';
		return 0 if $what eq 'allow';
	    }
	}

        # allow by default !
	return 0;
}

#
# do something
#

sub mainAction {

    if ( defined &$MyAction ) {
	&$MyAction();
    } elsif ( defined &$Action) {
	&$Action();
    } elsif ( -e "$WBLib/$Action" ) {	# separate file ?
	do wbDo ($Action);
    } elsif ( -e "$WBLib/$MyAction" ) {	# overloaded separate file ?
	do wbDo ($MyAction);
    } else {
	$m = <<EOM;
Maybe file '$WBLib/$Action' is missing.
<BR>Maybe full path to the above file is missing.
<BR>Maybe the upper/lower case of the filename (under UNIX) is wrong.
EOM
	do wbFail("Action '$Action' not implemented",$m);
    }

    do printFoot();
    do wodaExit();
}

sub wbDo {

	$_=shift (@_);;
	do "$WBLib/$_" unless defined &$_;	# load
	&$_(@_);				# execute
}

sub mainPathInfo {

	unless ($ENV{SCRIPT_NAME} =~ m|^/|) {
	    $ENV{SCRIPT_NAME} = "/$ENV{SCRIPT_NAME}";
	}

	$SCRIPT=$ENV{SCRIPT_NAME};

	# also support $SCRIPT?$key to show records
	#
	# PATH_INFO ... [/definition][/group:[password]][/Action]

	@x = split(/\//,$ENV{PATH_INFO});

	shift(@x);					# blank!
	unless ($x[0] =~ /\:/ || $x[0] =~ /[A-Z]/) {
	    if ($x[0]) {
	      $SCRIPT = "$SCRIPT/$x[0]";
	      # do $x[0]; ze prej !
	    }
	    shift (@x);
	}
 	if ($x[0] =~ /\:/ ) {
	    $SCRIPT = "$SCRIPT/$x[0]";
	    ($URLGroup,$URLPass) = split (/\:/,$x[0]);
	    shift(@x);
	}
	$Page = $x[0];

	# ToFrame ?

	if ($Page =~ m/ToFrame(.)$/ ) {;
	    $TargetDefault = "TARGET=_parent";
	    $InFrame=$1;
	    $Page = $`;
	} 

	local ($url,$method,$su);

	$method = $ENV{REQUEST_METHOD};
	if ($method eq 'GET') {
	    $su = $ENV{SERVER_URL};
	    chop($su);
	    $url = "$su$SCRIPT/$Page";
	    $url = $url . '?' . $ENV{QUERY_STRING} if $ENV{QUERY_STRING};
	    $url=&htEscape($url);
	    $Referer = "referer=$url";
	} else {
	    $Referer = '';
	}
}

sub mainCmdline {

	# command line interface
	# 
	# synopsis:
	# command -x PATH_INFO QUERY_STRING USERNAME:PASSWORD

	# $Group = $ENV{REMOTE_USER};
        # $Group = 'guest' unless $Group;

	if ($ARGV[0] eq '-x') {
	    $HTMLFILE = 1;			# prevent mime headers
	    $CMDLINE = 1;
	    do admGetEnv() || die "Environment not set from Admin menu\n";
	    $ARGV[1]="/$ARGV[1]" unless $ARGV[1] =~ m|/|; # one forgets /Search
	    $ENV{PATH_INFO} = $ARGV[1];
	    $ENV{QUERY_STRING} = $ARGV[2];
	    $ENV{QUERY_STRING} =~ s/^'//;	# DOS does not remove this from command line parameters
	    $ENV{QUERY_STRING} =~ s/'$//;	# same here

	    unless ($ENV{REQEST_METHOD}) { # true command line
		# simulte cookie for wbSetGroup; default is admin
	        $COOKIE{_user} = $ARGV[3] || 'admin:'; # Group defined in wbSetGroup
	    }
	    $ENV{REMOTE_ADDR} = $ENV{REMOTE_ADDR} || '127.0.0.1';
	    $ENV{REQUEST_METHOD} = 'GET';
	}
}

# --- end user routines ---------------------------------------------

sub printToolbar {

	@ub = split (',',$WBB{userMenuBrowse});
	@uf = split (',',$WBB{userMenuFind});
	@ua = split (',',$WBB{userMenuAdd});
	@uo = split (',',$WBB{userMenuOther});

	print <<'EOM';
<!-- 
Use these to add your own items to menues:
$WBB{userMenuBrowse}
$WBB{userMenuFind}
$WBB{userMenuAdd}
$WBB{userMenuOther}
Use $WBB{rights} to remove from menues!
-->
EOM

	# --- A-Z indexes

	undef @az;
	if ($WBB{AZindex}) {
	    @x = split (/\n/,$WBB{AZindex});
	    foreach $_ (@x) {
		($id,$x,$desc) = split (/\s+/,$_,3);
		push (@az, $desc, "$SCRIPT/BrowseAZ?name=$id");
	    }
	}

	# --- ring

	if ($r = &wbRingField()) {
	    $t = "Ring of pages pointed by $r"; #UK
	    push (@az,$t,"$SCRIPT/BrowseRing");
	}

	# --- browsing stuff

	undef (@fields);
	do wbBrowseDefaults();
	$f = join (', ',@fields);

	if ($#fields>=0) {
	    foreach $field (@fields) {
		if ($WBF{$field,'typePar'} =~ m/TREE/) {
	    	    $t = "Hierarchy of '$field'"; #UK
		    push (@az,$t,"$SCRIPT/BrowseTree?field=$field");
		}
	    }
		    
	    $t = "By one keyword from fields $f"; #UK
	    push (@az,$t,"$SCRIPT/BrowseContents");

	    $t = "By multiple keywords from fields $f"; #UK
	    push (@az,$t,"$SCRIPT/BrowseKeywords");

	}

	if ($#fields>=1) {
	    $t = "Combinations from list"; #UK
	    push (@az,$t,"$SCRIPT/BrowseMatrixList");
	}

	if ($#fields>=2) {
	    $t = "Combinations by form"; #UK
	    push (@az,$t,"$SCRIPT/BrowseMatrixForm");
	}

	if ($r = $WBB{basketName}) {
	    $t = "Show your $r"; # e.g. Show shopping list ; #UK 
	    push (@ua,$t,"$SCRIPT/BasketShow?editable=1");
	}

	$x = <<EOM ; #UK
Browse
All records
EOM

	@x = split (/\n/,$x);

	do printMenuTitle ("<IMG SRC=$ICONURL/browse.gif $ICONPAR ALT=browse> $x[0]");
	do printMenuItems (
		@az,@ub,
		$x[1],"$SCRIPT/Search?",
);

	$x = <<EOM ; #UK
Find
Simple search
What's new
Advanced search
A record by key
EOM
	@x = split(/\n/,$x);

	do printMenuTitle (	"<IMG SRC=$ICONURL/search.gif $ICONPAR ALT=search> $x[0]");
	do printMenuItems(
		        "$x[1]","$SCRIPT/SearchForm",
			"$x[2]","$SCRIPT/NewForm",
		        "$x[3]","$SCRIPT/AdvancedSearchForm",
		        "$x[4]","$SCRIPT/SearchIDForm",
			@uf);

	$x = <<EOM ; #UK
Personal
Login / logout
<B>Add</B> your information
Who are you, cookies
Review your subscriptions
Database administration
EOM

	@x = split(/\n/,$x);

	do printMenuTitle ("<IMG SRC=$ICONURL/uother.gif $ICONPAR ALT=info> $x[0]");
	do printMenuItems (
#		"$x[1]","\"></A>$lurl<hack",
		"$x[1]","$SCRIPT/LoginForm?$Referer",
		"$x[2]","$SCRIPT/Add",
		"$x[3]","$SCRIPT/About?user=1",
		"$x[4]","$SCRIPT/AgentReviewWhat",
	        @ua,
		"$x[5]","$SCRIPT/AdmMenu"
		);





	$x = <<EOM ; #UK
Other
General information
Database structure
Home of the WODA tool
EOM
	@x = split(/\n/,$x);

        do printMenuTitle ("<IMG SRC=$ICONURL/info.gif $ICONPAR ALT=add> $x[0]");
        do printMenuItems (
		"$x[1]","$SCRIPT/About",
		"$x[2]","$SCRIPT/DisplayStructure",
		"$x[3]",$WBHome,
		@uo);

}

sub cgiHome {


	do printHead ("Home Page") ; #UK

        print <<EOM;

<!-- you might want to replace this with a static .html file and then set WBB{homePage} -->
<TABLE CELLPADDING=0 BORDER=0>
<TR VALIGN=TOP>
<TD CLASS=SIDEBAR>
EOM
	
	do printToolbar();
	print "\n</TD>\n\n<TD>\n<!-- rest -->\n";

	print &wbSearchForm();
        print "<P>";

	print $WBB{about};

	# --- tree

	unless ($WBB{tree} eq '') {

	    $tree = &wbTree($WBB{tree},$WBB{treeSplit});

	    print $tree;
        }

	print "\n</TD></TR>\n</TABLE>\n";
	if ($WBB{spiderURL}) {
	    print "<A HREF=$WBB{spiderURL}/toc.htm> </A>";
	}
}

sub cgiAbout {
    do printHead ("About $WBB{dbTitle}") ; #UK

    undef @p;
    undef @v;
    foreach $x (sort(keys(%COOKIE))) {
	push (@p,$x);
	push (@v,"<A HREF=\"$SCRIPT/ResetCookie?cookie=$x&$Referer\">
<IMG $ICONPAR ALIGN=TOP SRC=$ICONURL/del.gif ALT=delete></A> " . $COOKIE{$x});
    }

    $cooks = &formatNameVal(@p,@v);

    undef @p;
    undef @v;
    @p = (
	"About this database",		#UK
	"Database manager",		#UK
	"Underlying database engine",	#UK
	"Translations by",		#UK
	"Access count",			#UK
	"You are user",			#UK
	"You are belong into group",	#UK
	"Your persistent information stored in cookies"	#UK
    ) ;

    ($ac,$since)=&wbAccessData();
    $since=&formatDate($since);
    $times = "Accessed $ac times since $since";	#UK

    @v = ($WBB{about},
	 "<A HREF=\"mailto:$WBB{managerEmail}\">$WBB{manager}</A>",
	 "<A HREF=\"$WBHome\">WODA</A> $VERSION $WBlanguage</A>",
	 $WBlanguageAuthor,
	 $times,
	 $User || "anonymous",
	 $Group,
	 $cooks );

    if ($CGI{user}) {
	@p=@p[5..7];
	@v=@v[5..7];
    } else {
	@p=@p[0..4];
	@v=@v[0..4];
    }

    print &formatNameVal(@p,@v);
}

#
# cgiAdd
#

sub cgiAdd {

	undef %rec;

	$x = $WBB{recordTitle} || '<!-- WBB{recordTitle} -->';
	do printHead ("New <!-- WBB{recordTitle} --> $WBB{recordTitle}") ; #UK

	$reset = "Undo edits" ; #UK
	$submit = "Continue to Preview ..." ; #UK

	$x = &wbForm(); # sets has userfile

	$enctype = "";
	$enctype = 'ENCTYPE="multipart/form-data"' if $WBB{hasUserFile};

	print <<EOM;
<DIV ALIGN=LEFT>
<FORM $enctype ACTION="$SCRIPT/Changed" METHOD=POST>
$x
<P>
<INPUT TYPE=SUBMIT VALUE="$submit">
<INPUT TYPE=RESET  VALUE="$reset">
</FORM></DIV>
EOM
	print $WBB{formFoot};
}

sub correct {

	print "<HR>\n";

	$x = &wbForm();
	$reset = "Undo edits" ; #UK
	$submit = "Continue to Preview ..." ; #UK

	$enctype = "";
	$enctype = 'ENCTYPE="multipart/form-data"' if $WBB{hasUserFile};

	print <<EOM;
<DIV ALIGN=LEFT>
<FORM $enctype ACTION="$SCRIPT/Changed" METHOD=POST>
$x
<P>$INPUTON
<INPUT TYPE=HIDDEN NAME="_id" VALUE="$CGI{'_id'}">
<INPUT TYPE=HIDDEN NAME="_dPassword" VALUE="$CGI{'_dPassword'}">$INPUTOFF
<INPUT TYPE=SUBMIT VALUE="$submit">
<INPUT TYPE=RESET VALUE="$reset">
</FORM></DIV>
EOM
}

sub cgiChanged {

	# set cookies for sticky stuff

	$x = &wbCookieCGI();

	# headers

	do printHead ("Confirm Edits",$x) ; #UK

	if ($CGI{_password} ne $CGI{_password1}) {
	    print "<P CLASS=ERROR>";
	    print "The two passwords do not match!" ; #UK
	    return;
	}

	$oldId = $CGI{_id};

	# --- test password if old record

	if ($oldId) {
	    do wbParseFile("$WBB{'dataDir'}/$oldId.rec",1);
	    $oldPass = $rec{_password};
	    $to = "$WBB{dataDir}/$oldId.rec";
            if (! &wbTestPass ($CGI{_dPassword},$oldPass) && -s "$WBB{'dataDir'}/$oldId.rec") {
		if (&isOwner()) {
		    # OK ... we own the old record
		} else {
                    do wbBadPass();
                    return;
		}
            }

	    # xxx admin group should not corrupt password !!!

	    if ($ADMINPASS) {
		print "<P CLASS=ERROR>";
		print "Bad password entered by administrator.<BR>Existing password will be preserved.</P>\n"; #UK
		$oldRec{_password} = $rec{_password};
	    }

	    # preserve values we were not allowed to edit in oldrec

	    foreach $x (keys(%rec)) {
		next if $WBF{$x,modifies} eq '';		# everyone modifies
		next if $Group =~ m/admin|$WBF{$x,modifies}/;	# I modify
		$oldRec{$x} = $rec{$x};				# I don't modify
	    }

	    # --- create the savedRec field

	    %savedRec = %rec;

	} else {		# --- new
	    $to = '';
	}

        $err  = &wbCgiToRec(); 

	# print %rec;

	# --- merge in old values

	foreach $x (keys(%oldRec)) {
	    $rec{$x}=$oldRec{$x};
	}

	# --- compute key

	if ($WBB{key}) {
	    $x = $WBB{key};
	    $newId = eval $x;
	    $newId = &wbFixId($newId);
            $to = "$WBB{dataDir}/$newId.rec";

	    # print $to;

	    # fail if key exists and we are not editing old one

	    if ((! $oldId) && -e $to) {
	        print <<EOM ; #UK
<H3 CLASS=ERROR>Error!<BR>
Record with the same key data exists <A HREF=\"$SCRIPT/Show?_id=$newId\">here</A>.
</H3>
EOM
		return;
	    }
	    
	    # warn if key changed

	    if ($oldId && $newId ne $oldId) {
	        print <<EOM ; #UK
<H3 CLASS=WARN>Warning!<BR>
You have changed key data in this record.
New record will be added to the database,
old one will need to be deleted!
</H3>
EOM
	    }

	}

        $text = &wbRecPrint();

	$tmpFile = &wbTmpFile("$TMPDIR",'rec');

	# print $tmpFile;

	unless (open (h,">$tmpFile")) {
		print ("Cannot create $tmpFile") ; #UK
		return;
	}

	binmode(h);
	print h $text;
	close h;

	$err  = &wbParseFile($tmpFile,0);
	$html = &wbRecHtml();
        $text = &wbRecPrint();

	print <<EOM ; #UK
Nothing has been saved (yet). Please review what you entered
and confirm at the bottom of this page.
<P>
$html
EOM

	if ($err) {
	    $x = "<IMG SRC=$ICONURL/del.gif ALT=Error $ICONPAR>";
	    print <<EOM ; #UK
<H3 CLASS=ERROR>Errors were discovered !</H3>
<PRE>$err</PRE>
EOM
	
	    if ($Group eq 'admin') {
		print "<P CLASS=ERROR>... but you are an admin and you should know better than I do"; #UK
	    } else {
	    	print <<EOM; #UK
<H3>Please correct the fields with errors below.
They are marked with $x.</H3>
EOM
		do correct();
		return;
	    }
	
	} else {
	    print "<H3>No errors</H3>But please <B>manually</B> check <B>all links</B>!\n" ; #UK
	}
	
	$x = "Save the information into the database" ; #UK
	$recFiles = join('|',@recFiles);	

	print <<EOM;
<FORM ACTION=$SCRIPT/Store METHOD=POST>
<INPUT NAME=from VALUE="$tmpFile" TYPE=HIDDEN>
<INPUT NAME=to VALUE="$to" TYPE=HIDDEN>
<INPUT NAME=files VALUE="$recFiles" TYPE=HIDDEN>
<INPUT TYPE=SUBMIT METHOD=POST VALUE="$x">
<BR>
</FORM>
EOM
}

sub cgiLoginForm {
	$NOFOOT=1;

	local ($cgiProg,$a);

	$t = "Login/logout"; #UK

	do printHead($t); 

	if ($SCRIPT =~ m|(/[^/:]+\:[^/]*)|) {
	    print <<EOM;
<P CLASS=ERROR>
You cannot login as another user if you are specifying the username in the URL. Remove the '$1'
portion of the URL and try again.
EOM
	    return;
	}


	print "<P><SMALL>";

	if ($a=$WBB{userTable}) {
	    $dir = &wbTables('DIR',$a);
	    $url = &getRelatedURL($dir);
	    if ($User eq '') {
		if ($WBB{userTable}) {
		    print "<B>All users of this database should be registered</B>."; #UK 
		} else {
		    print "Registration of users is optional."; #UK
		}

		print <<EOM; #UK
To register, please fill-in 
<A HREF="$url/Add">this form</A>.
If you registered before
type your id and the password that you used to lock
your registration information. Otherwise use one
of the anonymous usergroups (e.g. <I>guest</I>) as username.
EOM

	    } else {
		print "You are logged in as <B>$User</B>."; #UK
	    }

	} else {

	    print "You belong to group of users <B>$Group</B>."; #UK

	}

	print <<EOM; #UK
<P><SMALL>To log in as somone else
enter new username and password.
To log out, enter a blank username.
This information will be stored on <I>your workstation</I>
as a cookie.
EOM

	# persistent cookie for username !

@p = ("Group or user name","Password","",""); #UK
@v = (	"<INPUT SIZE=8 NAME=groupname VALUE=\"$CGI{groupname}\">",
	"<INPUT SIZE=8 NAME=password TYPE=PASSWORD>",
	"<INPUT NAME=referer VALUE=\"$CGI{referer}\" TYPE=HIDDEN>",
	"<INPUT TYPE=SUBMIT VALUE=\"$t\""
     );

	$x = &formatNameVal(@p,@v);

	$w = $CGI{win} || 'x';

	print <<EOM;
<FORM ACTION="$SCRIPT/Login" METHOD=POST>
$x
<INPUT NAME="win" VALUE="$w" TYPE=HIDDEN>
</FORM>
EOM
}

sub cgiLogin {

	$cscope = $WBB{userScope} || $ENV{SCRIPT_NAME}; 

	if ($CGI{groupname} ne '') {
	    $CookieGroup = $CGI{'groupname'};
	    $CookiePass = $CGI{'password'};
$wbsg='';
	    $URLGroup = '';	# ignore whatever group was supplied so far			
	    do wbSetGroup();
# do wbFail($wbsg);
	    if ($Group eq $CGI{'groupname'} || $User eq $CGI{'groupname'}) {
		$ok=1;
	    } else {
		$ok=0;
	    }

	    $cookie = &htFormatCookie(	'_user',
					"$CGI{groupname}\:$CGI{password}",
					$cscope,
					"SESSION");
	} else { # logout
	    $cookie = &htFormatCookie('_user',
					"$CGI{groupname}\:$CGI{password}",
					$cscope,
					"RESET");
	    $cookie .= &htFormatCookie('_group',
					"a",
					$cscope,
					"RESET");
	    $cookie .= &htFormatCookie('_voucher',
					"b",
					$cscope,
					"RESET");


	    undef (%COOKIE);
	    $CookieGroup = '';
	    $CookiePass = '';
	    $URLGroup = '';
	    $URLPass = '';
	    do wbSetGroup();
	    $ok=1;
        }

	$user = $User || 'anonymous';
	$t = "Logged in as user $user from group $Group"; #UK
	
	if ($ok) {
	    do printHead("$t\n",$cookie);
	} else {
	    do printHead("Login failed\n"); #UK
	    print "<P CLASS=ERROR>Bad password!</P>\n"; #UK
	}

#	print &formatTmpWinClose() unless $CGI{win} eq 'self';
	$hr = "$ENV{SCRIPT_NAME}/$CGI{groupname}\:$CGI{password}/Home";

	if ($CGI{referer}) {
	    $go = <<EOM; #UK
<A HREF=$CGI{referer}>go back</A>
EOM
	} else {
	    $go = <<EOM; #UK
<FORM>
<INPUT TYPE=BUTTON VALUE="go back" onClick="history.go(-2);">
</FORM>
<P>and reload that page.
EOM
	}

	print <<EOM; #UK
<P> You can now
$go
<P><BR>If you disabled cookies you can use  
<A HREF="$hr">URL
based login</A>.
<P>
EOM
	return;

	print <<EOM; #UK
<P> You can now go to <A HREF="$SCRIPT/Home">home page</A> of this database and use it as $user from $Group.

<P CLASS=WARN>COOKIE based login/logout fails with some versions of Internet Explorer. Try something like:
<BR><A HREF="$hr" TARGET=_opener>$hr</A>.
This one opens in a new window!
EOM
}

sub cgiDebug {

    do printHead("Useful Data for Debuging and Troubleshooting");

    print "<H3>CGI</H3><PRE>";

    foreach $x (sort(keys(%CGI))) {
	print "$x='$CGI{$x}'\n";
    }

    print "</PRE><H3>ENV</H3>";

    foreach $x (sort(keys(%ENV))) {
	print "$x=$ENV{$x}<BR>\n";
    }

    print "<H3>COOKIE</H3>";

    foreach $x (sort(keys(%COOKIE))) {
	print "'$x'=$COOKIE{$x}<BR>\n";
    }

    print "<H3>WHO AM I</H3><PRE>";

    for $var ('WBPath','WBFile','WBLang','WBLib','WBProg','PERLV','^X') {
	$value = eval "\$$var";
	print "\$$var = $value\n";
    }


    print "</PRE><BR>---END OF DEBUG DATA--<HR>\n";

}

sub cgiDelete {
	do printHead ("Delete record $CGI{_id}") ; #UK

	($p,$a) = ("Password you assigned to this information","Delete") ; #UK

	print <<EOM;
<FORM ACTION=$SCRIPT/DeleteIt METHOD=POST>
$p:<BR>
<INPUT TYPE=PASSWORD SIZE=10 NAME="_dPassword">
<P>
<INPUT TYPE=HIDDEN NAME="to" VALUE="$WBB{dataDir}/$CGI{_id}.rec">
<INPUT TYPE=SUBMIT VALUE="$a!">
</FORM>
EOM
}

sub cgiDeleteIt {

	do printHead("Delete results") ; #UK

	$to = $CGI{to};

	do wbParseFile("$to",1);
	if (! &wbTestPass($CGI{_dPassword}, $rec{_password})) {
		print "<H3 CLASS=ERROR>Bad password,delete failed</H3>" ; #UK
		do wbBadPass();
		return;
	}

	# related files (.bak into original)

	$mvret = '';
	if ( $to =~ m/(.*).rec$/ ) {	
	    @all = &glob("$1.*");
	    foreach $x (@all) {
		next if $x =~ m/bak$/;
		$mvret .= &wbMoveFile ("$x","$x.bak");
		print "Moved $x to $x.bak<BR>\n";
	    }
	}

	if (-e $to) {
	    print "<H3 CLASS=ERROR>Delete failed</H3>"      ; #UK
	    print "$mvret\n";
	    return;
        }

        print "<H3>Record deleted</H3>" ; #UK
	do wbDatabaseChanged();

        print <<EOM ; #UK
<H3>Thank you for cleaning $WBB{'dbTitle'}.</H3>
<H3>Undo ?</H3>

To undo the deletion just made, press below:
<FORM ACTION=$SCRIPT/Undo>
<INPUT NAME=file VALUE="$CGI{to}" TYPE=HIDDEN>
<CENTER><INPUT TYPE=SUBMIT VALUE="Undelete!"</CENTER>
</FORM>
EOM


}


sub printDeny {

	$title = "Access denied"; #UK

	if ($userAllowFailed) {
	    $message = <<EOM; #UK
As <B>$User</B> you are not allowed to
use this database. Try to access it as 
'guest'.
EOM
        } else {
	    $message = <<EOM; #UK
Users from group $Group are not allowed to request $Page.
EOM
	}

	do wbError($title,$message);
}

sub cgiEdit {

	$id = &wbFixId($CGI{_id});
	$file = "$WBB{'dataDir'}/$id.rec";
	do wbParseFile ($file,1);
	if ( &isOwner() ) {
	    do cgiEditForm();
	} else {
	    do printHead ("Edit record $CGI{_id}") ; #UK

	    ($p,$a) = ("Password you assigned to this information","Edit ...") ; #UK

	    print <<EOM;
<FORM ACTION="$SCRIPT/EditForm" METHOD=POST>
$p:<BR>
<INPUT TYPE=PASSWORD SIZE=10 NAME="_dPassword">
<BR>
<INPUT TYPE=HIDDEN NAME="_id" VALUE="$CGI{_id}">
<P>
<INPUT TYPE=SUBMIT VALUE="$a">
</FORM>
EOM
	}
}

sub cgiEditForm {

	$id = &wbFixId($CGI{_id});
	do printHead ("Edit $id") ; #UK
	$file = "$WBB{'dataDir'}/$id.rec";

	if ( -s $file) {
	    $x = time;
	    do wbParseFile ($file,1);
	    $oldPass = $rec{_password};
            if ( &isOwner() || &wbTestPass ($CGI{_dPassword},$oldPass)) {

		# OK

	    } else {
            	do wbBadPass();
		return;
            }

	} else {
	    print "<P CLASS=WARN>Record did not exist";
	    undef %rec;
	    $rec{id} = $CGI{_id};
	    $rec{id} = &wbFixId($CGI{_id});
	}

	$x = &wbForm();
	$reset = "Undo edits" ; #UK
	$submit = "Continue to Preview ..." ; #UK

	$enctype = "";
	$enctype = 'ENCTYPE="multipart/form-data"' if $WBB{hasUserFile};

	print <<EOM;
<DIV ALIGN=LEFT>
<FORM $enctype ACTION="$SCRIPT/Changed" METHOD=POST>
$x
<P>
<INPUT TYPE=HIDDEN NAME="_id" VALUE="$CGI{'_id'}">
<INPUT TYPE=HIDDEN NAME="_dPassword" VALUE="$CGI{'_dPassword'}">
<INPUT TYPE=SUBMIT VALUE="$submit">
<INPUT TYPE=RESET VALUE="$reset">
</FORM></DIV>
EOM
	print $WBB{formFoot};
}

sub cgiGo {

	$_id = $CGI{_id};
	$to = $CGI{to};
	$sort = $CGI{'sort'};
	$search = $CGI{'search'};

	if ($sort eq '') {
	    do wbFail("Undefined sort");
	}

	do wbSearch ($search,'',$sort,'NIL');

	if ($to eq 'first') {
	    $i=0;
	} elsif ($to eq 'last') {
	    $i=$#ids;
	} else {
	    $i=0;
	    foreach $id (@ids) {
	        last if $id eq $_id;
	        $i++;
	    }

	    $i++ if $to eq 'next';
	    $i-- if $to eq 'previous';

	}

	if ($i < 0 || $i > $#ids) {
	    do printHead ("No such record $i");

	} else {
	   $_id = $ids[$i];
	   $CGI{_id} = $_id;
	   do wbDo ("cgiShow");
	}
}

sub cgiNewForm {

	do printHead ("News Form") ; #UK

	$submit = "   L i s t   " ; #UK
	$newsin = "news in the last" ; #UK
	$unit   = "days." ; #UK
	$newsince = "news since my last listing of the news" ; #UK
	$nocookie = "On their next visit, users of browsers that support cookies also see option `What's new since my last visit?`\n" ; #UK

	if ($COOKIE{NEWS}) {

	    $x = &formatDate($COOKIE{NEWS});
	    $newsince .= " <B>$x</B>.";

	    print <<EOM;
<TABLE CLASS=SEARCH><TR><TD>
<FORM METHOD=GET ACTION="$SCRIPT/Search">
<INPUT TYPE=SUBMIT VALUE="$submit">
$newsince
<INPUT NAME=since VALUE=$COOKIE{NEWS} TYPE=HIDDEN>
<INPUT TYPE=HIDDEN NAME="sort" VALUE="TIME">
<INPUT TYPE=HIDDEN NAME="cookie" VALUE="NEWS">
</FORM>
</TD></TR></TABLE>
EOM

	} else {
	    print "<P><B>$nocookie</B><P>";
	}

	print <<EOM;
<P>
<TABLE CLASS=SEARCH><TR><TD>
<FORM METHOD=GET ACTION="$SCRIPT/Search">
<INPUT TYPE=SUBMIT VALUE="$submit">
$newsin
<INPUT NAME=days SIZE=3 VALUE=7>
<INPUT TYPE=HIDDEN NAME="sort" VALUE="TIME">
<INPUT TYPE=HIDDEN NAME="cookie" VALUE="NEWS">
$unit
</FORM>
</TD></TR></TABLE>
EOM


}

sub cgiParam {

	do printHead ("Cgi parameters");

	print "<PRE>\n";
	foreach $x (keys(%CGI)) {
		print "<B>$x</B>=$CGI{$x}\n";
	}

	foreach $x (keys(%ENV)) {
		print "<B>$x</B>=$ENV{$x}\n";
	}

}

sub cgiQuery {

	do wbDo ("cgiSearch",'HF');
}

sub printSearchFrames {

	$how = 'COLS' if $CGI{frames} =~ m/^V(.*)$/;
	$how = 'ROWS' if $CGI{frames} =~ m/^H(.*)$/;
	$proc = $1 || 50;

	$qs = $ENV{QUERY_STRING};
	$qs =~ s/frames\=.//;

	print $HTTP200OK . "Content-type: text/html\n\n";
	print <<EOM;
<HEAD>
<TITLE>Search Results in Frames</TITLE>
</HEAD>
<FRAMESET $how="$proc%,*">
<FRAME SRC="$SCRIPT/SearchToFrameL?$qs" NAME="woda_list">
<FRAME SRC="$ICONURL/powrwoda.gif" NAME="woda_detail">
</FRAMESET>
<NOFRAMES>
EOM

	print <<EOM;	#UK
Your browser should support frames to use this type of search.
EOM

	print "</NOFRAMES>\n";
	do wodaExit();
}
	
# USES:
# 	CGI{search}	... what
# 	CGI{sort}	... DEFAULT, TIME, sort1, sort2 ...
# 	CGI{format}	... DEFAULT, LONG, format1, format2 ...
#	CGI{first}	... 0
#	CGI{max}	... 20
#	CGI{days}	... younger than x days
#	CGI{noshit}	... nothing but results

sub cgiSearch {

	local ($how) = @_;
	# how = HF or H or F or empty
	# means not HEAD, not FOOT

	$yh = 1 unless $how =~ /H/;
	$yf = 1 unless $how =~ /F/;

	$CGI{'search'} =~ tr/\n/ /; # many search fields on line

	# frames

	if ($CGI{frames} =~ /^H|^V/) {
	    do printSearchFrames();
	}

	if ($InFrame) {
            $TargetDetail = "TARGET=woda_detail";
	    $SuffixDetail = "ToFrameD";
            $TargetDefault= "TARGET=woda_detail";
	    $SuffixDefault= "ToFrameD";
            $TargetParent = "TARGET=_parent";
	    $SuffixSelf   = "ToFrameL";
	    $TargetSelf   = "TARGET=_self";
	}

	$time = time;

	if ($CGI{search} =~ m/%20/) {
	    $CGI{search} = &htUnescape($CGI{search});
	}

	if ($CGI{cookie} eq 'NEWS') {
	    $cookie = &htFormatCookie('NEWS',$time);
	} else {
	    $cookie = "";
	}

	if ($CGI{'format'} =~ m/^CSV/) {
	    $yh=$yf=0;
	    print "Content-type: application/xls\n\n";
	}

	$criteria = '';
	$op = $CGI{grouping};
	for ($i = 1; $i<=$nCriteria; $i++) {
	    $f = $CGI{"f:$i"};
	    next if $f eq '';
	    $e = $CGI{"e:$i"};
	    $v = $CGI{"v:$i"};

	    $e =~ s/x/$v/;
            $criteria .= " {$f} $e $op";
	}

	$criteria =~ m/$op$/;
	$criteria = $`;

	$CGI{search} .= $criteria;

	# remember the search expressions

	if ($CGI{search} ne '') {
	    local (@s,$s,$y);
	    @s = split(/\n/,$COOKIE{search});
	    $y=1;
	    foreach $s (@s) {
		if ($s eq $CGI{search}) {
		    $y=0;
		    last;
		}
	    }
	    if ($y) {
	        @s = ($CGI{search},@s);
	        @s = @s[0..4];
	        $s = join("\n",@s);
	        $cookie .= &htFormatCookie('search',$s);
	    }
	}

	if ($yh) {
	    do printHead ("Search Results",$cookie) ; #UK
	}

        if ($yh && $CGI{search}) {
	    $x = &wbSearchForm($CGI{search});
	    print $x;
	}

	$CGI{first} =  0 if ! $CGI{first};
	$CGI{max}   = $WBB{dfltHits} if ! $CGI{max};
	$CGI{max}   = $WBB{maxHits} if $CGI{max}>$WBB{maxHits};

	# hidden stuff

	undef %seen;
	do wbSortFields();
	foreach $x (@PFields) {
	    if ($CGI{"x:$x"}) {
		$seen{$x} = 1;
	    }
	}

	if (defined %seen) {
	    foreach $x (@PFields) {
		$Hidden{$x} = 1 unless $seen{$x};
	    }
	}

	# do it in table format

	$CGI{'format'} = 'DEFAULT' unless $CGI{'format'};
	if ($CGI{'format'} eq 'DEFAULT' && ! $WBB{'format;DEFAULT'}) {
	    $f = '';
	    foreach $x (@PFields) {
		next if $x =~ m/^_/;
		if ($WBF{$x,'type'} !~ /AREA/) {
		    $f .= "\$rec{'$x'} ";
		}
	    }
	    $f = "\"$f\"";
	    $WBB{'format;DEFAULT'}=$f;
	    # $CGI{'format'} = 'TABLE';
	}

	$search = $CGI{'search'};

	$then = 0;
	$then = time - 24*3600*$CGI{'days'} if $CGI{'days'};
	$then = $CGI{'since'} if $CGI{'since'};

	# do the search

	$allHits = &wbSearch ($search,$then,$CGI{'sort'},$CGI{'format'},$CGI{'first'},$CGI{'max'});
	$dataHits = $#list+1;

	# what did we get back

	$n = $CGI{first}+1;
	$m = $CGI{first}+$dataHits;
	        
	#print "must include: " . join(',',@aWords) . "<BR>\n" if @aWords;
	#print "must not include: " . join(',',@nWords) . "<BR>\n" if @nWords;
	#print "may include: " . join(',',@sWords) . "<BR>\n" if @sWords;

	if ($dataHits) {
	    if ($yh) {
	        print "<H3>Hits $n to $m of $allHits " ; #UK
	    }
	} else {
	    if ($yh) {
                print "<H3>No hits.</H3>" ; #UK
	        return;
	    } else {
	    	do wodaExit() unless $yf;
	    }
	}

	$more = 0;
	$newFirst = $CGI{first} + $CGI{max};
	undef @first;

	if ($allHits != $dataHits) {
	    $more = 1 if $allHits > $CGI{first}+$CGI{max};
	    $j=0;
	    for ($i=0;$i<$allHits;$i+=$CGI{max}) {
		@first[$j]=$i;
		$j++;
	    }
	}

	# reformat links

	if ($dataHits > 0 && $yh && 0) {		# disabled

	    print "... reformat as \n";	#UK

	    $qs = $ENV{QUERY_STRING};
	    @altTexts = (
"short",			#UK
"short into frame",		#UK
"detailed",			#UK
"detailed into frame"		#UK
);

	    @formats = ("DEFAULT","DEFAULT","LONG","LONG");
	    @frames =  ("NONE","V33","NONE","V");

	    $qs = $ENV{QUERY_STRING};
	    $qs =~ s/\&format=\w+//;	# erase format info
	    $qs =~ s/\&frames=\w+//;	# erase frames info
	    $i=0;
	    foreach $x (@altTexts) {
		$nqs = $qs . "&format=$formats[$i]&frames=$frames[$i]";

		print <<EOM;
 [<A HREF="$SCRIPT/Search?$nqs" $TargetParent> $x </A>]
EOM
		$i++;
	    }

	}

	print "</H3>\n" if $yh;

	# print params

        $x=$CGI{first}+1;
	$cgif=$CGI{'format'};

	$head = &formatFoundHeader($cgif);
	do formatFoundSeparators($cgif,$x);
	
	if ($cgif ne 'RAW' && $dataHits) {
	    print "<DIV ALIGN=LEFT>" unless $cgif =~ m/^CSV/;
	    print <<EOM unless $PrintingBasket || $HTMLFILE || !$WBB{basketName};
<FORM ACTION="$SCRIPT/BasketAdd" TARGET=woda_basket
onSubmit='window.open(	"",
			"woda_basket",
			"scrollbars=yes,resizable=yes,menubar=yes,width=600,height=300"
		);'
>
EOM
	    print $t0,$head;
	    foreach $_ (@list) {
	        print "$t1$_$t2";
	    }
	    print $t3;
	    $add = "Add checked items to $WBB{basketName}"; #UK
	    print "</DIV>" unless $cgif =~ m/^CSV/;
	    print <<EOM unless $PrintingBasket || $HTMLFILE || !$WBB{basketName};
<INPUT TYPE=SUBMIT VALUE="$add">
</FORM>
EOM


	} else {
	    foreach $_ (@list) {
	        print "$t1$_$t2";
	    }
	}

	do wodaExit() unless $yf;

	# ce je se kaj odgovorov

	undef @Toolbar;

	if (@first) {
	
	    print "<P>For more results click below:" ; #UK
	    $qs = $ENV{QUERY_STRING};
	    $qs =~ s/\&first=\d+//;

	    $tale = -1;
	    for ($j=0;$j<=$#first;$j++) {
		if ($first[$j] == $CGI{first}) {
		    $tale=$j;
		    last;
		}
	    }

	    for ($j=0;$j<=$#first;$j++) {

		$newFirst = $first[$j];

		if ( $j != 0 && $j != $#first && $j != $tale &&	($tale-$j)*($tale-$j)>25 ) {
 		    if (! $pikce) {
		    	push (@Toolbar,<<EOM);
...
EOM
		    	$pikce=1;
		    }
		    next;
		}

		$pikce=0;
		$qsn = $qs . "&first=$newFirst";
		$pg = "show page $j";	#UK
		$pg0 = "this is page $j"; #UK

		if ($j == $tale) {
	    	    push (@Toolbar,<<EOM);
<IMG BORDER=0 SRC=$ICONURL/up.gif ALT="$pg0">
EOM
		} elsif ($j == 0) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/first.gif ALT="$pg"></A>
EOM
		} elsif ($j == $tale-1) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/back.gif ALT="$pg"></A>
EOM
		} elsif ($j == $tale+1) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/forward.gif ALT="$pg"></A>
EOM

		} elsif ($j == $#first) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/last.gif ALT="$pg"></A>
EOM

		} elsif ($j < $tale) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/backg.gif ALT="$pg"></A>
EOM
		} elsif ($j > $tale) {
	    	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/Search$SuffixSelf?$qsn" $TargetSelf><IMG BORDER=0 SRC=$ICONURL/forwardg.gif ALT="$pg"></A>
EOM
		}

	    }
	} else {
	   if ($dataHits) {
	   print "<P>No more hits." ; #UK
	   }
        }

	if (&agentGroup() && ! $agentFile) {

	    $text =  "I want Angie to find me this from time to time."; #UK
	    $text2 = "subscribe"; #UK
	    local ($s,$so,$fo);
	    $s  = &htEscape($CGI{'search'});
	    $so = &htEscape($CGI{'sort'});
	    $fo = &htEscape($CGI{'format'});
	    push (@Toolbar,<<EOM);
<A HREF="$SCRIPT/AgentAddForm?search=$s&sort=$so&format=$fo" $TargetParent>
<IMG $ICONPAR ALIGN=TOP SRC=$ICONURL/angie.gif ALT="$text"></A>
EOM
	}

}

sub formatFoundSeparators {

	local ($format,$n) = @_;

	if ($format eq 'CSV' || $format eq 'CSVS') {
	    $t0="";
	    $t1="";
	    $t2="\n";
	    $t3="";
	} elsif ($format eq 'TAB') {
	    $t0="<XMP>\n";
	    $t1="";
	    $t2="\n";
	    $t3="</XMP>\n";
	} elsif ($format eq 'RAW') {
	    $t0="";
	    $t1="";
	    $t2="\n";
	    $t3="";
	} elsif ($format eq 'TABLE') {
	    $t0="<TABLE CLASS=DATA>\n";
	    $t1="";
	    $t2="";
	    $t3="</TABLE>\n";
	} elsif ($format eq 'LONG' || $format eq 'NAMEVAL') {
	    $t0="";
	    $t1="";
	    $t2="<HR>\n";
	    $t3="";
	} elsif ($format eq 'DEFAULT' || $format =~ m/^\d$/) {
	    $t0=$WBB{"formatHead$format"};
	    $t1='';
	    $t2='';
	    $t3=$WBB{"formatFoot$format"};
	}
}

sub cgiSearchForm {

	do printHead("Simple search form");

	print &wbSearchForm($CGI{search});

}

sub cgiSearchAgain {

	if ($COOKIE{search}) {
	    @s = split (/\n/,$COOKIE{search});
	    $n = $#s + 1;
	    do printHead("Search again in recent $n searches"); #UK
	    foreach $s (@s) {
		print &wbSearchForm($s);
	    }
	} else {
	    do cgiSearchForm();
	}
}

sub cgiSearchIDForm {

	do printHead ("Search by record ID") ; #UK

	print <<EOM ; #UK
<TABLE CLASS=SEARCH><TR><TD>
<FORM ACTION=$SCRIPT/Show>
Show what record:
<BR><INPUT NAME=_id SIZE=40>
<BR><FONT SIZE=2>Enter record key.</FONT>
</FORM>
</TD></TR></TABLE>
EOM

}

# (names,values)
sub wbFormatOptions {

	local (*v,*t,$default) = @_;
	local ($nItems,$i);

	$nItems = $#v;
	$_ = '';
	foreach ($i=0; $i<=$nItems; $i++) {
	    if ($default ne '' && $default eq $v[$i]) {
	    	$_ .= "<OPTION VALUE=\"$v[$i]\" SELECTED>$t[$i]\n";
	    } else {
	    	$_ .= "<OPTION VALUE=\"$v[$i]\">$t[$i]\n";
	    }
	}

	return $_;
}
	

sub formatFormats {

	local ($selected) = @_;

	@vals = ("DEFAULT", "LONG", "TABLE", "CSV", "CSVS", "TAB");
	@texts = (
"default short format",			#UK
"default detailed format",		#UK
"table format - one record per row",	#UK
"comma delimited format (.csv)",	#UK
"semicolon delimited format (.csv)",	#UK
"tab delimited format"			#UK
	);

	if ($WBB{detail}) {
	    push (@vals,  "NAMEVAL");
	    push (@texts, "tabular detailed format");	#UK
	}

	$formats = &wbFormatOptions(*vals,*texts,$selected);
	@x = keys %WBB;
	@x = grep (/^formatName/,@x);
	foreach $_ (@x) {
	    $v = $WBB{$_};
	    $_=m/(\d)$/;
	    $text=$1;
	    $formats .= "<OPTION VALUE=$text>$v\n";
	}

	return $formats;
}

sub cgiAdvancedSearchForm {

	do printHead ('Advanced Search') ; #UK

	# --- sorts

	@vals = ("DEFAULT","TIME","CUSTOM");
	@texts = ("by number of matches","new items first");	#UK

	$sorts = &wbFormatOptions(*vals,*texts);
	@x = keys(%WBB);
	@x = grep (/^sortName;/,@x);
	foreach $_ (@x) {
	    $v = $WBB{$_};
	    ($s,$text) = split (/;/);
	    $sorts .= "<OPTION VALUE=$text>$v\n";
	}

	# --- formats

	$formats = &formatFormats(); # OPTION LIST READY

	# --- sorts

	@vals = ("NONE","V","V66","V33","H");
	@texts = (
"no frames",			#UK
"vertical",			#UK
"vertical - small detail",	#UK
"vertical - big detail",	#UK
"horizontal"			#UK
);

	$frames = &wbFormatOptions(*vals,*texts);

	# what fields to include

	do wbSortFields();
	undef (@flds);
	foreach $x (@PFields) {
	     $ch='';
	     $ch = 'CHECKED' unless $x =~ m/^_/;
	     push (@flds,"<INPUT NAME=\"x:$x\" TYPE=CHECKBOX $ch> $x \n");
	}

	$flds = &formatColumns(4,@flds);

	# the field expression builder

	$fieldPull="<OPTION DEFAULT>\n";
	foreach $x (@PFields) {
	    $fieldPull .= "<OPTION>$x\n";
	}

	$opPull=<<EOM;
<OPTION VALUE="&amp;&amp;">and
<OPTION VALUE="||">or
<OPTION VALUE=")&amp;&amp;">)and
<OPTION VALUE=")&amp;&amp;(">)and(
<OPTION VALUE=")">)
EOM

	$brPull=<<EOM;
<OPTION>
<OPTION>(
EOM

	$grouping=<<EOM; #UK
<SELECT NAME="grouping">
<OPTION VALUE="and">satisfy all of the above
<OPTION VALUE="or">satisfy any of the above
</SELECT>
EOM

	$exprPull=<<EOM;
<OPTION VALUE="">
<OPTION VALUE="=~ m/x/">contains
<OPTION VALUE="=~ m/^x/">begins with
<OPTION VALUE="=~ m/x\$/">ends with
<OPTION VALUE="=~ m/x/">matches
<OPTION VALUE='eq "x"'>eq
<OPTION VALUE='ne "x"'>ne
<OPTION VALUE='gt "x"'>gt
<OPTION VALUE='lt "x"'>lt
<OPTION VALUE="=~ x">=~
<OPTION VALUE="== x">==
<OPTION VALUE="!= x">!= 
<OPTION VALUE="&gt; x">&gt; 
<OPTION VALUE="&lt; x">&lt;
<OPTION VALUE="&lt;= x">&lt;=
<OPTION VALUE="&gt;= x">&gt;= 
EOM

	$sex = '';
	for ($i=1;$i<=$nCriteria;$i++) {
	    $sex .= <<EOM;
<SELECT NAME="f:$i">
$fieldPull
</SELECT>
<SELECT NAME="e:$i">
$exprPull
</SELECT>
<INPUT NAME="v:$i" SIZE=15>
<BR>
EOM
	}

	$sex .= $grouping;

	@p= (
"Search for",		#UK
"Search!",		#UK
"Enter space separated list of words.", #UK
"Sorting",		#UK
"Formating",		#UK
"Frames",		#UK
"Results per page",	#UK
"Where applicable print the following fields",	#UK
"Additional search criteria",	#UK
);

	$xby = 'by'; #UK
	$xand = 'and'; #UK

	print <<EOM ; 
<FORM ACTION=$SCRIPT/Search>
<TABLE CLASS=SEARCH><TR><TD>
<TABLE>
<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[0]:</TD>
<TD><INPUT NAME=search SIZE=40> <INPUT TYPE=SUBMIT VALUE='$p[1]'>
<BR>
<FONT SIZE=2>$p[2]<A HREF=$WBhelp#search>HELP</A></FONT>
</TD></TR>

<TR>
<TD ALIGN=RIGHT VALIGN=TOP>$p[8]:</TD>
<TD>$sex</TD>
</TR>
<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[3]:</TD>
<TD><SELECT NAME=sort>
$sorts
</SELECT>
<!-- 
<BR>$xby <SELECT NAME=sort1>$fieldPull</SELECT>
$xand <SELECT NAME=sort2>$fieldPull</SELECT>
$xand <SELECT NAME=sort3>$fieldPull</SELECT>
-->
</TD></TR>

<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[4]:</TD>
<TD><SELECT NAME=format>
$formats
</SELECT>
</TD></TR>

<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[5]:</TD>
<TD><SELECT NAME=frames>
$frames
</SELECT>
</TD></TR>

<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[6]:</TD>
<TD><INPUT NAME=max VALUE=50 SIZE=3>
</TD></TR>

<TR><TD ALIGN=RIGHT VALIGN=TOP>$p[7]:</TD>
<TD>$flds</TD>
</TR>

</TABLE>
</TD></TR></TABLE>
</FORM>
EOM
}

sub cgiShow {
	# may use &PIC()

	$id   = $CGI{_id};
	$sort = $CGI{'sort'};

	$home = $WBB{'dataDir'};
	do wbParseFile("$home/$id.rec",1);
	do wbSetOwner();

	if ($Group ne 'admin' && $WBB{hideUnless} && ! eval $WBB{hideUnless}) {
	    do wbError ("This record is not available","User '$User' from group '$Group' is not allowed to see it"); #UK
	}

	if ($WBB{detail} ne '') {
	    do printHead();
	} else {
	    local ($x);
	    $x = eval $WBB{'detailTitle'} || "$WBB{'recordTitle'} $id <!-- see WBB{detailTitle} and WBB{recordTitle} -->";
	    do printHead ("$x");
	}

        $html = &wbRecHtml();
	print $html;

	do setShowToolbar();
}

# set record group to
# 	'owner' if the user is an owner
#	'public' if the record is not owned by anyone and user is anonymous
#	'other' in all other cases
#
# can't we live with isOwner only ???

sub wbSetOwner {

	undef $RGroup;

	if ($WBB{'ownerField'}) {
	    if ($rec{$WBB{ownerField}} eq $User) {
	        $RGroup = 'owner';
	    } elsif (($User eq 'anonymous' || $User eq '') && ($rec{$WBB{ownerField}} eq '0' || $rec{$WBB{ownerField}} eq '')) {
		$RGroup = 'public';
	    } else {
		$RGroup = 'other';
	    }
	} 
}

# is the logged in user the owner of the opened record

sub isOwner {

	do wbSetOwner();
	return $RGroup eq 'owner';
}

# returns 1 if this is the table used to
# verify usernames and passwords for
# loggin in

sub isLoginTable {

	local ($dataDir);
        $dataDir = &wbTables('DIR',$WBB{userTable});

	return $dataDir eq $WBB{dataDir};
}	

sub setShowToolbar {

	# buttons

	@hlps = (
"pick and add to $WBB{basketName}",	#UK
'modify the information',		#UK
'delete entire record',			#UK
'explain the meaning of the fields',	#UK
''
);
	@butts = ('PICK','EDIT','DELETE','LEGEND','FIRST','PREVIOUS','NEXT','LAST') ; #UK
	@acts =  ('BasketAddOne','Edit','Delete','DisplayStructure','Go','Go','Go','Go');
	@to   =  ('','','','','first','previous','next','last');
	@icons = ('basket','edit','del','info','first','back','forward','last');

	if (!$WBB{basketName}) {
	    shift @hlps;
	    shift @butts;
	    shift @acts;
	    shift @to;
	    shift @icons;
	}

	$ret = "";

	$i=0;
	foreach $act (@acts) {
	    if (&wbDenied($Group,$act)) {
		$i++;
		next;
	    }
	    if ($InFrame) {
	    	$act .= "ToFrameD";
		$target = "TARGET=_self";
	    } else {
		$target='';
	    } 
	    $x = &htEscape($id);
	    if ($icons[$i] =~ m/edit|del|back|forward|basket/) {
	        $params="_id=$x";
	    } else {
		$params="";
	    }
	    $extra='';	
	    if ($act =~ m/^Go/) {
		$params = $params . '&' if $params;
		$params.="sort=$sort&to=$to[$i]";
		if ($CGI{search} ne '') {
		    $s = &htEscape($CGI{search});
		    $params.="&search=$s";
	        }
		next unless $sort;
	    }

	    if ($act =~ m/^Basket/) {
		$target = 'TARGET=woda_basket';
	    }

	    $h = $hlps[$i] || $butts[$i];

	    $params = "?" . $params if $params;

	    push (@Toolbar,<<EOM);	#xxx
<A HREF="$SCRIPT/$act$params" $target><IMG 
$ICONPAR SRC="$ICONURL/$icons[$i].gif" ALT="$h"></A>
EOM
	    $i++;
	}
}

sub cgiStore {

#do printHead ("Store");
#print %CGI;
#exit;

	if (! (-s $CGI{from})) {
	    $x = $CGI{from};
	    do printHead("Update Failed"); #UK
	    print <<EOM; #UK
<P CLASS=ERROR>
The data entered through a form is no longer available.
Most likely it has already been stored into
a record and you tried to "Confirm Edits" twice
by using a "back" button on your browser.
The other possibility is that the disk is full.
<P>
EOM
	    return;
	}

	$home = $WBB{dataDir};
	$to = $CGI{to};

	# assign random name 

	if ($to eq "") {
	    $to = &wbTmpFile ($home,'rec');
	}

	# --- what is the id

	$to =~ m|/([^/]+)\.rec$|;
	$id = $1;

	# --- create backup copy

	do wbMoveFile ("$to", "$to.bak");

	# --- write record

        do wbMoveFile ("$CGI{from}", "$to");

	# --- files

	if ($CGI{'files'} eq "") {

	    # nothing

	} else {

	    # attached files

	    do wbParseFile($to,1); 

	    foreach $field (keys(%rec)) {
		if ($WBF{$field,type} eq "USERFILE" || $WBF{$field,type} eq "IMAGE") {
		    $fFrom = $rec{$field};	# file where to copy from (has .tmp)
		    $fFrom =~ m/([^\.]*)$/;     # extract .extention
		    $fTo = "$id.$field.$1";	# copy to (no tmp)

		    next if $fFrom eq $fTo;	# do nothing if equal

		    do wbMoveFile ("$fTo",   "$fTo.bak") unless ($fTo =~ m/\.tmp\./);
		    do wbMoveFile ("$fFrom", "$fTo");

		    $rec{$field} = $fTo;
		}
	    }

	    $keepUnderscores=1;
	    $text = &wbRecPrint();

	    open (h,">$to");
	    binmode(h);
	    print h $text;
	    close (h);
	}

	if ( ! (-s $to) ) {
            do printHead ("ERROR: Database Update Failed") ; #UK
	    unlink $to;
	    return;
        }

        do printHead ("Database Updated") ; #UK
	do wbDatabaseChanged();

	# print %CGI;

	# print "$fTo,$fFrom"; 
	# print $from,$to,%rec;

	$p = ":$ENV{SERVER_PORT}";
	$p = '' if $p eq ":80";
	$url = "http://$ENV{SERVER_NAME}$p$SCRIPT/Show?_id=$id";

        print <<EOM ; #UK
<H3>Thank you for contributing to $WBB{'dbTitle'}.</H3>

Your edits were saved at URL <P>
<CENTER><A HREF="$url">$url</A>.</CENTER>
<P>
This information may be useful to locate the record for editing or updating.
You may wish to <TT>[bookmark]</TT> it.

<H3>Undo ?</H3>

To undo the changes just made, press below:
<FORM ACTION=$SCRIPT/Undo>
<INPUT NAME=file VALUE="$CGI{to}" TYPE=HIDDEN>
<CENTER><INPUT TYPE=SUBMIT VALUE="Undo!"></CENTER>
</FORM>

<H3><A HREF="$SCRIPT/Add">Add another record</A></H3>

EOM

}

#
# display table of contents
#

sub cgiToc {

	do printHead ("Table of Contents") ; #UK

	print <<EOM;	#UK
This table of contents is intended for the
conveniance of Web spiders and crawlers. It is
not intended for humans!
EOM

	do wbSearch ('','','');

	foreach $item (@list) {
	    print "<BR>$print{$item}\n";
	}
}

sub cgiUndo {

	do printHead ("Undo changes") ; #UK

	$dFile = $CGI{file};

	if (-e "$dFile.bak") {
	    
	    do wbMoveFile ("$dFile.bak", "$dFile");

	    # files

	    $dFile =~ m/(.*).rec$/;	

	    @all = &glob("$1.*.bak");

	    foreach $x (@all) {
		$x =~ m/(.*).bak$/;
		do wbMoveFile ($x, $1);
	    }
	
	    do wbDatabaseChanged();
	    print "<H3>Undo was successful</H3>\n" ; #UK
	
	} else {

	    print <<EOM ; #UK
<H3 CLASS=ERROR>Undo failed</H3>
File $dFile.bak does not exist.
EOM

	}
}

sub cgiDisplayStructure {

	do printHead ("Information about fields in $WBB{dbTitle}"); #UK
	do printStructure('00000','^p$|^head$|^type$|^help$|^options$',1);
}

# prepares inarow and fields parameters for keyword and contents browse

sub wbBrowseDefaults {

	do wbSortFields();

	$inarow = $CGI{inarow} || 3;
	@fields=split(/,/,$CGI{fields});

	if ($#fields<0) {
	    foreach $field (@Fields) {
	    $t=$WBF{$field,'type'};
	    if ($WBF{$field,'type'} =~ m/^OPTION$/) {
		    push (@fields,$field);
		}
	    }
	}
}

sub cgiBrowseKeywords {

	do wbBrowseDefaults();
	$f = join (', ',@fields);

	do printHead("Browse by keywords in fields $f");	#UK

	print <<EOM;	#UK
<P>Check any keywords you are interested in then press the
search button at the end of this page. The items with more matched
keywords will be listed on top <I>or</I>
Click on keywords next to the checkboxes to search for records
belonging to that category only.
EOM
	print <<EOM;
<P>
<FORM METHOD=POST ACTION="$SCRIPT/Search">
EOM

	@items='';
	$dItem = 0;
	$dSearch='';

	foreach $field (@fields) {

	    $head = &formatFieldName($field);
	    @kwords = &wbParseOptions($field);
	    $print = "<B>$head</B><BR>\n";

	    foreach $kword(@kwords) {
		$x = &wbOptionWordSearch($field,$kword);
		$print .= <<EOM;
<INPUT TYPE=CHECKBOX NAME="search" VALUE="&quot;$kword&quot;">
<A HREF="$SCRIPT/Search?search=$x">$kword</A>
<BR>
EOM
		$dSearch++;
	    }

	    $items[$dItem++]=$print;
	}

	print "<TABLE CLASS=FORM>";

	for($i=0;$i<=$#items;$i+=$inarow) {
	    print "<TR VALIGN=TOP>\n";
	    for ($j=0;$j<$inarow;$j++) {
		$idx=$i+$j;
	        print <<EOM;
<TD>
$items[$idx]
</TD>
EOM
	    }
	    print "</TR>\n";
	}

	$search = "S e a r c h";	#UK
	$reset = "R e s e t";		#UK

	print <<EOM;
</TABLE>
<P><BR>
<INPUT TYPE=SUBMIT VALUE="   $search   ">
<INPUT TYPE=RESET VALUE="   $reset   ">
</FORM>
EOM

}

# browse contents

sub cgiBrowseContents {

	do wbBrowseDefaults();

	$icon="<IMG SRC=$ICONURL/search.gif $ICONPAR ALT=search>";
	$join="<BR>";

	if ($#fields == 0) {
	    $f = &formatFieldName($fields[0]);
	    do printHead("Browse by $f");	#UK
	} else {
	    $f = join (',',@fields);
	    do printHead("Browse by fields $f");	#UK
	}

	if ($CGI{comma}) {
	    $join=', ';
	    $icon='';
	}

	print <<EOM;				#UK
<P>Follow the links to find items tagged with the keyword</P>
EOM

	@items='';
	$dItem = 0;

	foreach $field (@fields) {

	    $head = &formatFieldName($field);
	    @kwords = &wbParseOptions($field);
	    $print = "<B>$head</B><BR>\n" if $#fields > 0;

	    @list=();
	    foreach $kword(@kwords) {
		$x = &wbOptionWordSearch($field,$kword);
		push (@list,"<A HREF=\"$SCRIPT/Search?search=$x\">$icon $kword</A>"); 
	    }

	    # $print .= &formatColumns(1,@list);
	    $print .= join ($join,@list);
	    $items[$dItem++]=$print;
	}

	print "<TABLE>";

	for($i=0;$i<=$#items;$i+=$inarow) {
	    print "<TR VALIGN=TOP>\n";
	    for ($j=0;$j<$inarow;$j++) {
		$idx=$i+$j;
	        print <<EOM;
<TD>
$items[$idx]
</TD>
EOM
	    }
	    print "</TR>\n";
	}

	print "</TABLE>";
}

sub cgiBrowseMatrixList {

	do printHead ("Select Browse Matrix Combination");	#UK

	print <<EOM;	#UK
This page lets you define a browse matrix. Select 
combination of two fields. Values of the first will be used for rows and
values of the second for columns. Note that matrices which would include
fields marked with a * may take longer to generate.

EOM

	do wbSortFields();
	foreach $field (@Fields) {
	    if ($WBF{$field,'type'} =~ m/OPTION$/) {
		push (@fields,$field);
		$nice = &formatFieldName($field);
		$nice .= " *" if $WBF{$field,'type'} eq 'LINKOPTION';
		push (@niceFields,$nice);
	    }
	}

	$opts='';
	for ($i=0;$i<=$#fields;$i++) {
	    $rn=$fields[$i];
	    $ru=&htEscape($rn);
	    $rv=$niceFields[$i];
	    print "<P><B>$rv</B><BR>\n";
	    for ($j=0;$j<=$#fields;$j++) {
		next if $i == $j;
	    	$cn=$fields[$j];
		$cu=&htEscape($cn);
	    	$cv=$niceFields[$j];
		print <<EOM;
<A HREF="$SCRIPT/BrowseMatrix?row=$ru&col=$cu">
$rv : $cv</A>
<BR>
EOM
	    }
	}
}




sub cgiBrowseMatrixForm {

	do printHead ("Define Browse Matrix");	#UK

	print <<EOM;	#UK
This page lets you define a browse matrix. Select 
one field name to display in rows and one to display in colums.
Search matrix will be generated so that you will be able to search for items
with row and column value.<P>
Note that matrices which would include fields marked with a * may take longer to generate.

	<FORM ACTION="$SCRIPT/BrowseMatrix">
EOM

	do wbSortFields();
	foreach $field (@Fields) {
	    if ($WBF{$field,'type'} =~ m/OPTION$/) {
		push (@fields,$field);
		$nice = &formatFieldName($field);
		$nice .= " *" if $WBF{$field,'type'} eq 'LINKOPTION';
		push (@niceFields,$nice);
	    }
	}

	$opts='';
	for ($i=0;$i<=$#fields;$i++) {
	    $n=$fields[$i];
	    $v=$niceFields[$i];
	    $opts .= "<OPTION VALUE=\"$n\">$v\n";
	}

	$c="Field to use for columns"; #UK
	$r="Field to use for rows";    #UK

	print <<EOM;
<TABLE BORDER=1>

<TR>
<TD><BR></TD>
<TD ALIGN=CENTER>
$c<BR>
<SELECT NAME="col">
$opts
</SELECT>
</TD>
</TR>

<TR>
<TD ALIGN=CENTER>
$r<BR>
<SELECT NAME="row">
$opts
</SELECT>
</TD>
<TD><BR></TD>
</TR></TABLE>
<P>
<INPUT TYPE=SUBMIT VALUE="   OK   ">
</FORM>
EOM
}

sub cgiBrowseMatrix {

	$field=$CGI{row};
	$field2=$CGI{col};

	do printHead("Browse Matrix by $field and $field2");    #UK
	print <<EOM; #UK
<P>Click on row or column headers to search for records belonging to that
category <I>or</I>
Click on the search icons to search for
a combination of row and column values.
EOM

	@rowWords=&wbParseOptions($field);
	@colWords=&wbParseOptions($field2);

	$rowTit = &formatFieldName($field);
	$colTit = &formatFieldName($field2);

	$nrows=$#rowWords+1+1+1;  # legend,title
	$ncols=$#colWords+1+1;
	$nc1=$ncols-1;

	print<<EOM;
<P><TABLE BORDER=1>
<TR>
<TH><BR></TH>
<TH COLSPAN=$nc1>
$colTit
</TH>
</TR>
<TR>
<TH>$rowTit</TH>
EOM

	# col headings

	foreach $colWord (@colWords) {
	    $x = &wbOptionWordSearch($field2,$colWord);
	    print "<TH><A HREF=\"$SCRIPT/Search?search=$x\">$colWord</A></TH>\n";
	}

	print "</TR>\n";

	# rows

	foreach $rowWord (@rowWords) {
	    $x = &wbOptionWordSearch($field,$rowWord);
	    print "<TR><TH ALIGN=RIGHT><A HREF=\"$SCRIPT/Search?search=$x\">$rowWord</A></TH>\n";
	    foreach $colWord (@colWords) {
		$search="+\"$colWord\" +\"$rowWord\"";
		$search = &htEscape($search);
	        $surl = "$SCRIPT/Search?search=$search";
		print <<EOM;
<TD ALIGN=CENTER VALIGN=MIDDLE>
<A HREF="$surl"><IMG $ICONPAR SRC="$ICONURL/search.gif" ALT="search"></A>
</TD>
EOM
	    } 	
	    print "</TR>\n";
	}

	print "</TABLE>\n";
}

# creates +field:"$word" and escapes it for url

sub wbOptionWordSearch {

	local ($field,$word) =@_;

	# $word =~ s/\(|\)|\//\\$&/g;	# escape ( ) and / in search words
	$word =~ s|[/()]|\\$&|g;	# escape ( ) and / in search words
	return &htEscape("+$field:\"$word\"");
}



########### # # # UTILITIES #######################################

sub formatAscRec {

	local ($x,$v,$out);

	$out = "";
	#if ($CGI{'_password'} ne "") {
	    $x = &wbCryptPasswd($CGI{'_password'},'wb'.substr($CGI{'_password'},0,2));
	    $out .= "%_password: $x\n";
	#}

	$from = $ENV{REMOTE_HOST};
	$from = $ENV{REMOTE_ADDR} if ! $from;
	$out .= "%_from: $from\n";

	$now = time;
	$out .= "%_at: $now\n";

	if ($#_ >=0) {
	    %x = @_;
	} else {
	    %x = %rec;
	}

        foreach $x (sort(keys(%x))) {

	    # skip system fields

	    next if $x =~ m/^\_/;	
            $v = $x{$x};
	    if ($WBF{$x,type} eq "TEXTAREA" || $WBF{$x,type} eq "HTMLAREA") {
		$v =~ s/\n/\n\t/g;
		$v = "\n\t$v";
		# chop ($v);	# last tab;
	    }
            $out .= ('%' . $x . ":\t$v\n");
        }

	return $out;
}

sub formatBinRec {

	local ($x,$v,$out);
	$LF = "\x0A";

	$out = "$LF";

#print <<EOM;
#<BR>keep = $keepUnderscores;
#<BR>recp = $rec{_password};
#<BR>cgip = $CGI{_password};
#<BR>ADMINPASS = $ADMINPASS;
#EOM

	if ($keepUnderscores && $rec{_password} && !$CGI{'_password'} || $ADMINPASS && $rec{_password}) {
	    $out .= "_password$LF$rec{_password}$LF";
	} else {
	    $x = &wbCryptPasswd($CGI{'_password'});
	    $out .= "_password$LF$x$LF";
	}

	$from = $ENV{REMOTE_HOST};
	$from = $ENV{REMOTE_ADDR} if ! $from;
	$from = $rec{_from} if $keepUnderscores;

	$out .= "_from$LF$from$LF";

	$now = time;
	$now = $rec{_at} if $keepUnderscores;
	$out .= "_at$LF$now$LF";

	if ($#_ >=0) {
	    %x = @_;
	} else {
	    %x = %rec;
	}

        foreach $x (sort(keys(%x))) {

	    # skip system fields

	    next if $x =~ m/^\_/;	
            $v = $x{$x};
	    $v =~ tr/\012/\034/;
	    $out .= "$x$LF$v$LF";
        }

#print length($out);
	return $out;
}

# writes entire _rec to file.rec provided as parameter
# returns number of fields written

sub wbWriteRec {

	local ($file) = @_;

	open (h,">$file.rec") || return 0;
	binmode(h);
	$LF = "\x0A";
	print h $LF;

        foreach $x (sort(keys(%rec))) {
            $v = $rec{$x};
	    $v =~ tr/\012/\034/;
	    print h "$x$LF$v$LF";
	}

	close (h);

	if ($rec{_at} > 0) {
	    utime $rec{_at}, $rec{_at}, "$file.rec";
	}
}
	
#
# print @items in $num columns
#

sub formatColumns {

	local ($num,@items)=@_;
	local ($ret,$left);

	$num = 1 if $num == 0;		# parachute
	$left=1+int(($#items)/$num);

	$ret = "<TABLE><TR>\n";
	for ($i=0;$i<=$#items;$i+=$left) {
	    $j = $i+$left-1;
	    $x = join("\n<BR>",@items[$i..$j]);
	    $ret .= "<TD VALIGN=TOP>$x</TD>\n";
	}
	$ret .= "</TR></TABLE>\n";
	return $ret;
}

# --- utilities -----------------------------------------------------

sub formatDate {

    local ($time) = @_;
    local (@x,$i);

    @x = localtime($time);

    @x[4]++;

    for ($i=0;$i <= $#x; $i++) {
	$x[$i] = "0" . $x[$i] if length($x[$i]) == 1;
    }

    if ($x[5]<100) {
	$x[5]=1900+$x[5];
    }

    return "$x[5]/$x[4]/$x[3] $x[2]:$x[1]";
}

# returns today's date formatted in a way
# proper for Woda date fields

sub TODAY {
    local ($d,$t);

    $d=&formatDate(time);
    ($d,$t)=split(/ /,$d);
    return $d;
}

# does nothing at all

sub NOOP {
}

# modifies $string so that it can be used
# as a record ID e.g. replaces does with undercsores

sub ID {
    local ($string)=@_;

    return &wbFixId($string);
}

sub formatField {

# to ne dela v big verziji, ce so funkcije izven paketa!

	local($field)=@_;
	local($x,$_);

	$_ = $rec{$field};

	    if ($WBF{$field,type} eq 'BREAK') {
		return '';
	    }

	    if ($WBF{$field,type} eq 'COMPUTE') {
	        $x = $WBF{$field,picture};
		return eval $x;
	    }

	    return '' unless $_;

	    # multiple options in OPTION or LINKOPTION
	
	    if ( $_ =~ m/\n/ && $WBF{$field,type} =~ m/OPTION$|^LIST$/ ) {
	        if ($pict = $WBF{$field,picture}) {
		    local ($ret) = '';
		    local ($_) = $_;
		    local (@items) = split (/\n/,$_);
		    foreach $_ (@items) {
			$ret .= eval $pict;
		    }
		    return $ret;
		} else {
		    $_ =~ s/\n/, /g;
		    return $_;
		}
	    }

	    # other options

	    if ($x = $WBF{$field,picture}) {

		return eval $x;

	    } elsif ($WBF{$field,type} eq "TEXTAREA") {
		if ($_ =~ m/<P|<BR/) {
		    return $_;
		} else {
		    local (@rows,$max,$row);
		    @rows = split (/\n/,$_);
		    $max=0;
		    foreach $row(@rows) {
			if (length($row) > $max) {
			    $max = length($row);
			}
		    }
		    if ($max > 60) {
			return "<TT>$_</TT>";
		    } else {
		        return "<PRE>$_</PRE>";
		    }
		}
	    
	    } elsif ($WBF{$field,type} eq "FILE") {
		return "<A HREF=\"$WBB{homeURL}/$rec{$field}\">$rec{$field}</A>";

	    } elsif ($WBF{$field,type} eq "IMAGE") {
		return "<IMG SRC=\"$WBB{homeURL}/$rec{$field}\">";

	    } elsif ($WBF{$field,type} eq "USERFILE") {
		$unit = 'bytes' ; #UK
		@x = stat ("$WBB{dataDir}/$rec{$field}");
		$rec{$field} =~ m/([^\.]*)$/;
	        $xt = $1;
		if ($xt =~ m/$FILETYPES/) {
		    $ic = "$ICONURL/$xt.gif";
		} else {
		    $ic = "$ICONURL/binary.gif";
		}
		return "<A HREF=\"$WBB{homeURL}/$rec{$field}\"><IMG $xt BORDER=0 ALIGN=TOP SRC=$ic> $rec{$field}</A> <TT>($x[7] $unit)</TT>";

	    } elsif ($WBF{$field,type} eq "URL") {
		return "<A HREF=\"$rec{$field}\">$rec{$field}</A>";

	    } elsif ($WBF{$field,type} eq "EMAIL") {
		return "<A HREF=\"mailto:$rec{$field}\">$rec{$field}</A>";

	    } else {
		return $rec{$field};
	    }
}

# formats values in %rec hash into %pic hash
# using instructions in $WBB{afield,picture} 

sub PIC {

	local ($field);
	undef %pic;

	do wbSortFields();
	foreach $field (@Fields) {
	    if (0 && $Hidden{$field}) {
		$pic{$field}='***';
	    } else {
		$pic{$field} = &formatField($field);
	    }
	}
}

sub formatFoundHeader {

	local ($format) = @_;
	local ($f,$hd,$ft);

	if ($format eq 'TABLE') {
	   $hd="<TR><TH> </TH>\n";
	} else {
	   $hd='';
	}

	do wbSortFields();
	foreach $f (@PFields) {
	    next if $Hidden{$f};

	    if ($format eq 'TABLE') {
		$hd .= "<TH>$f</TH>";
	    } elsif ($format eq 'TAB') {
		$hd .= "$f\t";
	    } elsif ($format eq 'CSV') {
		$hd .= "$f,";
	    } elsif ($format eq 'CSVS') {
		$hd .= "$f;";
	    }
	}

	if ($format eq 'TAB' || $format eq 'CSV' 
			     || $format eq 'CSVS') {
	    chop ($hd);
	}

	if ($format eq 'TABLE') {
	    $hd .= "</TR>";
	}

	$hd .= "\n";

	return $hd;
}

sub formatFoundFooter {
	return '';
}

sub formatFoundRow {

	local ($id,$format) = @_;

	local ($this,$open,$s);

	$s = &htEscape($CGI{search});

	# defined variables for use in the format definitions

	$this = "$SCRIPT/Show$SuffixDetail?_id=$id&sort=$sort&search=$s";
	$ThisRecordURL = $this;
	$ThisRecordDate = &formatDate($rec{_at});

	$ThisRecordMatches = $hits{$id};

	if ($Group eq 'admin' && ! $CMDLINE) {
	    $x = &htEscape ("$WBB{dataDir}/$id.rec");
	    $y = &htEscape ($id);
	    $z = 'HSPACE=0' if $format eq 'DEFAULT';
	    $ThisRecordIcons = "<A \nHREF=$SCRIPT/DeleteIt$SuffixDetail?to=$x><IMG \nSRC=$ICONURL/del.gif ALT=\"DEL\" $ICONPAR $z></A>" .
    "<A \nHREF=$SCRIPT/EditForm$SuffixDetail?_id=$y><IMG \nSRC=$ICONURL/edit.gif ALT=\"EDIT\" $ICONPAR $z></A>" .
    "<A \nHREF=$SCRIPT/AdmDelPass$SuffixDetail?_id=$y><IMG \nSRC=$ICONURL/delpass.gif ALT=\"DELPASS\" $ICONPAR $z></A> ";
	} else {
	    $ThisRecordIcons = '';
	}

	# --- provide the open icon

	if ($format eq 'DEFAULT' && $WBB{'format;DEFAULT'} =~ m/\$this/i) {
	    $ThisRecordIcons .= &formatOpenIcon('SMALL');
	} else {
	    $ThisRecordIcons .= &formatOpenIcon('');
	}

	# --- provide the basket checkbox unless 
	# 	we are writing the BASKET
	# 	we are pushing the page out via command line

	unless ($PrintingBasket || $CMDLINE || !$WBB{basketName}) {
	    $ThisRecordBasket = <<EOM;
<INPUT NAME="id$id" TYPE=CHECKBOX>
EOM
	}

	$print = '';

	if ($WBB{"formatRow$format"} ne '') {
	    $x = $WBB{"formatRow$format"};
	    #do wbFail("$x");
	    $print = eval $x || "EVAL ERROR:" . &htQuote($x);

	} elsif ($WBB{"format;$format"}) {

	    $x = $WBB{"format;DEFAULT"};
	    $print = eval $x || "EVAL ERROR:" . &htQuote($x);
	    $print = "<LI> $ThisRecordIcons $ThisRecordBasket $print \n";

	} elsif ($format eq 'TAB' || $format eq 'RAW') {
	    foreach $x (@PFields) {
		next if $Hidden{$x};
		$v = $rec{$x};
		$v =~ s/\t/\033/g;
		$v =~ s/\012/\034/g;
		$print = $print . $v . "\t"; 
	    }
	    chop $print;

	} elsif ($format eq 'CSV') {
	    foreach $x (@PFields) {		# kaj je to ???
		next if $Hidden{$x};
	        $v = $rec{$x};
	        $v =~ s/\"/\"\"/g;
	        $print = $print . '"' . $v . '"' . ','  ;
	    }
	    chop $print;

	} elsif ($format eq 'CSVS') {
	    foreach $x (@PFields) {		# kaj je to ???
		next if $Hidden{$x};
	        $v = $rec{$x};
	        $v =~ s/\"/\"\"/g;
	        $print = $print . '"' . $v . '"' . ';'  ;
	    }
	    chop $print;

	} elsif ($format eq 'TABLE') {
	    $print = "\n<TR VALIGN=TOP><TD>$ThisRecordIcons $ThisRecordBasket</TD>\n";
	    foreach $x (@PFields) {
		next if $Hidden{$x};
		$value = &formatField($x);
		$print = $print . "<TD>$value</TD>\n"; 
	    }
	    $print .= "<TR>\n";


	} elsif ($format eq 'LONG') {
	    $print = $ThisRecordBasket . &wbRecHtml();

	} elsif ($format eq 'NAMEVAL') {
	    $print = $ThisRecordBasket . &wbRecHtml('NAMEVAL');

#	} elsif ($WBB{"format;$format"}) {
#	    $x = $WBB{"format;$format"};
#	    $print = eval $x;

	} else {

	    $print = eval $format;
	}
		 
	return $print;
}

sub formatHiddenSearchPar {
	local ($x,$name,$val);

	$x = <<EOM;
<INPUT TYPE=HIDDEN NAME="first" VALUE="$newFirst">
EOM
	foreach $name (keys(%CGI)) {
	    next if $name eq "first";
	    $val = $CGI{$name};
	    $val =~ s/\"/\&quot\;/g;	# escape quotation marks!
	    $x .= <<EOM;
<INPUT TYPE=HIDDEN NAME="$name" VALUE="$val">
EOM
	}

	return $x;	     

#	return <<EOM;
#<INPUT TYPE=HIDDEN NAME="search" VALUE="$x">
#<INPUT TYPE=HIDDEN NAME="sort" VALUE="$CGI{'sort'}">
#<INPUT TYPE=HIDDEN NAME="days" VALUE="$CGI{'days'}">
#<INPUT TYPE=HIDDEN NAME="since" VALUE="$CGI{'since'}">
#<INPUT TYPE=HIDDEN NAME="format" VALUE="$CGI{'format'}">
#<INPUT TYPE=HIDDEN NAME="max" VALUE="$CGI{'max'}">
#EOM


}

# utputs name/value pairs in a table
# input: name1,name2,name3,name4,value1,value2

sub formatNameVal {

	local ($v0) = ($#_+1)/2;
	local ($i,$out);

	$out="<TABLE>\n";
	$v=$v0;
	for ($i=0;$i<$v0;$i++) {
	    $out .= "<TR VALIGN=TOP><TH ALIGN=RIGHT>$_[$i]</TH><TD>$_[$v]</TD></TR>\n";
	    $v++;
	}

	$out.="</TABLE>\n";

	return $out;
}

# set variable to display the OPEN icon

sub formatOpenIcon {

	local ($size) = $_[0]; 
	local ($hits) = $hits{$id};
	local ($num);

	if ($#sWords>=0) {
	    $num = $hits/($#sWords+1);
	} elsif ($then) {
	    $num = ($sort{$id}-$then)/($now-$then);
	} else {
	    $num = .60;
	}

	$iconpar = $ICONPAR;
	if ($size eq 'SMALL') {
	    $iconpar =~ s/WIDTH=../WIDTH=12/;
	    $iconpar =~ s/HEIGHT=../HEIGHT=12/;
	}

	$aa = 1;
	$aa = 2 if $num >.20;
	$aa = 3 if $num >.50;
	$aa = 4 if $num >.74;

	$proc = int($num*100+.5) . '%';

	return <<EOM;
<A HREF="$this"><IMG SRC=$ICONURL/$ICONOPEN$aa.gif $iconpar ALT="$proc; open"></A> 
EOM
	
}

sub formatPasswdInput {

	local ($n1,$n2)=@_;
	local ($out,$p1,$p2);

	$p1 = "again" ; #UK

	$out= "<INPUT TYPE=PASSWORD NAME=\"$n1\">\n";
	if ($n2) {
	    $out .= "$p1 <INPUT TYPE=PASSWORD NAME=\"$n2\">\n";
	}

	return $out;
}

sub formatHtm2Txt {
	local ($page) = @_;

	local ($row, $tag, $pad, $content, $x, @rows);

	$asciiPage = '';
	$* = 1;

	@rows = split (/</,$page);
	foreach $row (@rows) {
	    $row =~ tr/\n\r/  /;
	    $row =~ m/^([^>]+)>(.*)$/;
	    $tag = "<$1>";
	    $content = $2;
	    $content =~ s/^\s/ /;	# leading space
	    $content =~ s/\s$/ /;	# trailing space
	    $content =~ s/\s+/ /;	# multiple space
	    if ($tag =~ /<TITLE>|<OPTION>|<\!\-\-/i) {
		next;
	    } else {
	    }
	    if ($tag =~ /<P|<BR>|<LI|<H1|<H2|<H3|<H4|<OL|<UL/i) {
		$pad = "\n ";
	    } else {
		$pad = "";
	    }
	    $asciiPage .= "$pad$content" if $pad || $content;
	}
	$* = 0;
	return $asciiPage;
}
#	$asciiPage =~ s/\s+/ /g;
#	$asciiPage =~ s/^\s+//g;
#	$asciiPage =~ s/ \*/\*/g;
#	$asciiPage =~ s/\* /\*/g;
#	$asciiPage =~ s/\*+/\*/g;
#	$asciiPage =~ s/\*/ \* /g;
#	$asciiPage =~ s/^[\* ]+//g;
#	$* = 0;
#	return;
#}

sub formatSearchPar {

	local (@v,@p);

	@p = ('Words','Since','Sort','Format') ; #UK
	@v = ($CGI{'search'},&formatDate($CGI{'since'}),$CGI{'sort'},$CGI{'format'});

	return &formatNameVal(@p,@v);
}

# fetches $url and returns the part of page
# between A NAME=PAGEBODYN tags
# or whole page if that is not found
#
# this function may not work on some
# windows httpd servers (IIE, Xitami)

sub FETCH {
	local ($url)=@_;

	undef ($ok,$headers,$page);
	($ok,$headers,$page) = &fetchPage($url);

	if (!$ok) {
	    return $page;

	} else {
	    local ($*);
	    $*=1;
	    local ($h,$b,$f) = split(/\<A NAME=PAGEBODY.\>/,$page);
	    return $b || $page;

	}
}

# returns ok,header,page

sub fetchPage {

	$_ = $_[0];
	local ($host,$dir,$them,$port);

	# --- parse URL

	#print "parameter=$_";

	m|http://(.*)|;
	$url = $1;
	($host,$dir) = split (/\//,$url,2);
	$dir = "/$dir";
	($them,$port)= split(/:/,$host,2);
	$port = 80 unless $port;

	#print "url=$url;dir=$dir;port=$port;host=$host\n";

	# --- setup sockets

	# $SIG{'INT'} = 'dokill';

	$sockaddr = 'S n a4 x8';
	($name,$aliases,$proto) = getprotobyname('tcp');
	($name,$aliases,$type,$len,$thisaddr) =	gethostbyname('localhost');
	($name,$aliases,$type,$len,$thisaddr) =	gethostbyname($name);
	# funny but without the above line it crashes on win95

	($name,$aliases,$type,$len,$thataddr) = gethostbyname($them);
	$this = pack($sockaddr, $AF_INET, 0, $thisaddr);
	$that = pack($sockaddr, $AF_INET, $port, $thataddr);

	socket(S, $AF_INET, $SOCK_STREAM, $proto) || return (0,$!,$!); 
	bind(S, $this) || return (0,$!,"$! ... at bind");

	# above line fails with some PC perls or with XITAMI?

	connect(S,$that) || return (0,$!,"$! ... at connetc");

	select(S);
	$|=1;
	select(STDOUT);
	print S "GET $dir HTTP/1.0\nUser-agent: WODA\n\n";
	@page = <S>;
	close (S);

	$header = '';
	$page = '';
	while (@page) {
	    $line = shift (@page);
	    if ($line eq "\n" || $line eq "\r\n") {
		$page = join ('',@page);
		@page = ();
	    } else {
		$header .= $line;
	    }
	}
	return (1,$header,$page);
}

# is there a record with id=$id in
# table $table ?

sub KEY {
	local ($table,$id)=@_;
	local ($dataDir,$dataFile,$_);

	$dataDir = &wbTables('DIR',$table);
	$dataFile = "$dataDir/$id.rec";
	return -f $dataFile;	    
}

# get a value of field $name of record $id fromt table $table
# $tabe must be defined in $WBB{tables}

sub FLD {
	local ($table,$id,$name)=@_;
	local ($dataDir,$dataFile,$_);

	if ($VALid eq "$table/$id") {

	    # cache !

	} else {
	    $dataDir = &wbTables('DIR',$table);
	    $dataFile = "$dataDir/$id.rec";
	    %xrec = %rec;
	    do wbParseFile($dataFile,1);
	    %VALrec = %rec;
	    $VALid  = "$table/$id";
	    %rec=%xrec;
	}

	return $VALrec{$name};	    
}

# get raw data (tab separated) from $table
# similar to QRY function with $format=RAW
# $flds are comma separated field names

sub ROWS {
	local($table,$flds,$search,$then,$sort,$format,$first,$max)=@_;
	$max = 9999 || $max;
	do QRY($table,$search,$then,$sort,'RAW',$first,$max,$flds);
}

# Performs a search in table $table
# and returns results formatted in HTML
# parameters correspond to CGI parameters
# of standard or advanced search
#
# Fails on some Windows Web servers such as IIE
# that don't let you call another Perl program.
#
# Run Debug info from Admin menu to check if it
# has a chance of working. 

sub QRY {
	local ($table,$search,$then,$sort,$format,$first,$max,$flds) = @_;
	local ($ddir,$cgiPrg,$queryString,$dir,$prog,@x);

	$cgiPrg = &wbTables('DEF',$table);
	unless ($cgiPrg) {
	    return "ERROR - Table $table not defined";
	}

	$ddir = &wbTables('DIR',$table);
	unless (-s "$ddir/_cache/env") {
	    return "ERROR using QRY function: Environment not set for $table.
Administartor should set from his/hers menu.";
	}

	$_ = &htEscape($search);
	$queryString .= "search=$_&" if $_;

	$_ = &htEscape($then);
	$queryString .= "then=$_&" if $_;

	$_ = &htEscape($sort);
	$queryString .= "sort=$_&" if $_;

	$_ = &htEscape($format);
	$queryString .= "format=$_&" if $_;

	$_ = &htEscape($first);
	$queryString .= "first=$_&" if $_;

	$_ = &htEscape($max);
	$queryString .= "max=$_&" if $_;

	@flds = split (/,/,$flds);
	foreach $fld (@flds) {
	    $queryString .= "x%3A$fld=on&";
	}

	chop($queryString);	# remove the &

	$cgiPrg =~ m|(.+)/([^/]+)$|;

	$dir = $1;
	$prog = $2;

	### cacheing comes here ###

	$cacheFile = "$WBB{dataDir}/_cache/qry/$table-$queryString.txt";
	if (&wbExpired($cacheFile,$ddir)) {
	    mkdir ("$WBB{dataDir}/_cache/qry/",0777);
	    # go to data dir then run it
	    chdir ($dir);
	    $reply = `$PERL $prog -x Query '$queryString'`;
	    chdir ($WBB{dataDir});
	    open (qry,">$cacheFile");
	    print qry $reply;
	    close (qry);
	} else {
	    open (qry,$cacheFile);
	    @x = <qry>;
	    close (qry);
	    $reply = join ('',@x);
	}
	return $reply;
}

# print the end of each page

sub printFoot {

    print "<A NAME=PAGEBODY2>";

    do wbAccessCount();

    unless ($NOFOOT) {

	#
	# custom stuff for toolbar
	#

	if ($WBB{toolbar} ne '') {
	    @x = split(/\n/,$WBB{toolbar});
	    foreach $x (@x) {
		($patt,$string)=split(/\s+/,$x,2);
		if ($Page =~ m/$patt/) {
		    $x = eval $string || $string;
		    push (@Toolbar,$x);
		}
	    }
	} 

	#
	# prepare system stuff for toolbar
	#

	if ($NO_TIMES) {
	    $x="?";
	} else {
	    @x = times;
	    $x = $x[0]+$x[1]+$x[2]+$x[3];
	    # $x = int ($x*100+.5);
	    # $x = $x /100.;
	    $x = sprintf ("%5.2f",$x);
	}

	if ($Group eq 'Admin') {
	    # nothing
	} else {
	    $admtxt = "<!-- $admtxt -->\n";
	}

	$homeURL = &homeURL();

	if ($Group eq 'admin' || $Group eq 'guest') {
	    $uicon="u$Group";
	} else {
	    $uicon="uother";
	}

	local ($hh,$w,$u);

	if ($User) {
	    $us = "$Group&nbsp;$User";
	} else {
	    $us = "$Group";
	}

	$hh = "Home page of this database"; #UK
	$w = "Web Oriented Database Home";
	$u = "LOGIN (you are $us)"; #UK
	$hh = "HOME"; #UK

	$lurl = "$SCRIPT/LoginForm?$Referer";

	push (@Toolbar,<<EOM);
<A HREF="$homeURL" $TargetParent><IMG 
$ICONPAR SRC="$ICONURL/home.gif" ALT="$hh"></A>
EOM

	push (@Toolbar,<<EOM);
<A HREF=$lurl><IMG
$ICONPAR SRC="$ICONURL/$uicon.gif" ALT="$u"></A>
EOM

	if ($WBB{pageEnd} ne '') {

	    print eval $WBB{pageEnd};

	} else {

	        # default ...

		# convert toolbar into a table ...

		$toolbar = join ("</TD>\n<TD CLASS=TOOLBAR>",@Toolbar);
		$toolbar = "<TD CLASS=TOOLBAR>$toolbar</TD>";

		# get rid of whitespace

		$toolbar =~ s/>\n/>/g;
		$toolbar =~ s/>/\n>/g;

		# print some set stuff

		print "<BR>\n";
		print $WBB{"foot;$Page"} || "\n<!-- WBB{foot;$Page} would be here -->";

		# print the toolbar

		$x = $WBB{"toolbarText"} || "&nbsp;<!-- WBB{toolbarText} -->";

		print <<EOM;
<BR>
<TABLE WIDTH=100% HEIGHT=21 BORDER=0 CELLSPACING=0 CELLPADDING=2>
<TR>
$toolbar 
<TD CLASS=TOOLBAR WIDTH=100% ALIGN=CENTER>$x</TD>
<TD CLASS=TOOLBAR WIDTH=100%>
<A HREF=$WBHome/ $TargetParent><IMG BORDER=0 SRC=$ICONURL/powrwoda.gif ALT="$w" WIDTH=76 HEIGHT=21></A></TD>
</TR>
</TABLE>
EOM
	}

    } # unless $NOFOOT

    print $WBB{'pageFoot'} || "\n<!-- WBB{pageFoot} would be here -->";
    print "\n<!--WODA MESSAGES:\n\n$Log\n-->\n";
    print "\n</BODY>\n</HTML>\n";
}

sub homeURL {

    if ($WBB{homePage}) {
	if ($WBB{homePage} =~ m|/|) {
	    $homeURL = $WBB{homePage};
	} else {
	    $homeURL = "$WBB{homeURL}/$WBB{homePage}";
	}
    } else {
        $homeURL = "$SCRIPT/Home";
    }

    return $homeURL;
}

# --- head and foot ---

sub printMiniHead {

    $MINIHEAD=1;
    do printHead(@_);
}

sub printLocation {

    local ($location,$cookie) = @_;

# do wbFail($location);

    print $cookie;
    print "Location: $location\n\n";
    do wodaExit();
}


sub printHead {
    
    local ($pgTitle,$cookie) = @_;
    local ($homeURL,$dbTitle,$scriptURL,$p);

    # remove tags from title

    $pgT = $pgTitle;
    $pgT =~ s/<[^>]*//g;
    $pgT =~ s/>//g;

    # make sure no funny stuff gets out on DOS

    binmode(STDOUT);

    unless ($HTMLFILE) {
	if ($WBB{intlCharset} ne '') {
	    $chs = "; charset=$WBB{intlCharset}";
	} else {
	    $chs = '';
	}
        print $HTTP200OK . "Content-type: text/html$chs\n";
        print $cookie;
	print $DemandedCookies;
        print "\n";

	$Log .= "Cookies:\n";
	$Log .= $cookie;
	$Log .= $DemandedCookies;

        $HtmlHeaderPrinted = 1;
    }

    $dbTitle = $WBB{dbTitle};
    print "<HTML><HEAD>\n<TITLE>$dbTitle: $pgT</TITLE>
<META NAME=GENERATOR VALUE=\"WODA $VERSION - $WBHome\">\n";

    if ($chs) {
	print <<EOM;
<META HTTP-EQUIV="Content-Type" CONTENT="text/html$chs">
EOM
    }

    $p = $q = '';
    $p = ":$ENV{SERVER_PORT}" if $ENV{SERVER_PORT} != 80;
#   $q = "?$ENV{QUERY_STRING}" if $ENV{QUERY_STRING} ne '';
    print "<BASE HREF=http://$ENV{SERVER_NAME}$p$ENV{SCRIPT_NAME}$ENV{PATH_INFO}$q>\n" if $HTMLFILE;
    print "<BASE $TargetDefault>\n" if $TargetDefault;
    # this is the default style sheet, there is no need to change it here
    # just write your own definition into $WBB{style} and it will
    # override it
    if ($WBB{style}) {
	print <<EOM;
<STYLE TYPE="text/css">
<!-- 
$WBB{style}
--></STYLE>
EOM
    } else {
        print <<EOM;
<!-- because WBB{style} not defined -->
<STYLE TYPE="text/css">
<!-- 
	.error { background-color: #F88; }
	.warn { background-color: yellow; }

	BODY {
	    font-size: 10pt;
	    font-family: Arial,sans-serif;
	    background-color: white;
	}
	
	TT,PRE,CODE,SAMP { font-size: 10pt; font-family: fixed,Courier,Courier New; }

	TD,TH,P,H1,H2,H3,H4,LI,DD,OL,UL { font-size: 10pt; font-family: Arial,sans-serif; }

	TD,TH,P,LI,DD,OL,UL { font-size: 10pt; }

	H1 { font-size: 14pt; }
	H2 { font-size: 13pt; }
	H3 { font-size: 11pt; }
	H4 { font-size: 11pt; }

	A {text-decoration: none}

	.SS { font-family: sans-serif; } /* to compensate for a bug in Netscape*/

	.SEARCH, .FORM {
		background-color: #CCC;
		border-style: none;
		align: middle;
		vertical-align: center;
		
	}

	.TITLE {
		background-color: #CCC;
		font-size: 13pt;
	}

	.DATA1 {
		background-color: #CCC;
	}


	.DATA0 {
		background-color: #EEE;
	}


	.SIDEBAR {
		background-color: #CCC;
	}

	.MENU {
		background-color: #CCC;
		text-align: left;
		vertical-align: center;
	}

	.MENUT {
		background-color: #AAA;
	}

	.TOOLBAR { 
		background-color: #CCC;
		vertical-align: center;
	}

	TABLE.TOOLBAR A:visited { color: #000 }
	TABLE.TOOLBAR A:link { color: #000 }
-->
</STYLE>
EOM
    }
    print "</HEAD>\n\n";

    # body

    $pb = $WBB{pageBody};
    print "<BODY $pb>\n<!-- body parameters came from WBB{pageBody} -->\n";

    print $WBB{pageHead} || "<!-- WBB{pageHead} not defined -->";

    # advertizing ?

    if ($WBB{adFile} && ! $HTMLFILE && ! $MINIHEAD) {
	($url,$text,$img) = &wbGetAd($WBB{adFile});
	if ($img ne '') {
            print <<EOM;
<CENTER><A HREF="$url"><IMG SRC="$img" ALT="$text" BORDER=2></A></CENTER>
EOM
	} else {
	    print <<EOM;
<TABLE ALIGN=CENTER WIDTH=100% HEIGTH=64 BGCOLOR="FF00FF" BORDER=3>
<TR><TD ALIGN=CENTER>
<H2><BR><A HREF="$url">$text</H2>
</TD></TR>
</TABLE>
EOM
	}
    }

    print "<!-- WBB{adFile} not defined -->\n";

    if ($MINIHEAD) {
	print "<P><B>$pgT</B>";
	return; #################################
    }

    $homeURL = &homeURL();
    $scriptURL = $SCRIPT;
    $phi = $WBB{pageHeadIcon} || "<!-- WBB{pageHeadIcon} -->";

    if ($pgTitle) {
    	if ($WBB{pageTitle}) {
	    $x = eval $WBB{pageTitle};
	    print $x;
	} else {
            $x ="";
	    print <<EOM;
<TABLE WIDTH=100%>
<TR>
<TD CLASS=TITLE>
<!-- WBB{pageTitle} not defined -->
$phi
<A HREF="$homeURL" $TargetParent>
<SMALL>
<B STYLE=\"font-size:10pt\">$dbTitle</B>
</SMALL>
</A>
<BR>
<B>$pgTitle</B>
</TD>
</TR>
</TABLE>
<P>
EOM
	    print $WBB{"head;$Page"} || "<!-- WBB{head;$Page} would be here -->\n";
	}
    }

    print "<A NAME=PAGEBODY1>\n";

}

# --- items in cells

sub printMenuItems {

	@stuff = @_;
	local ($text, $url);

	print "<TABLE><TR><TD>\n";
	print "<FONT SIZE=-1>\n";
	for ($i=0; $i < $#_; $i+=2) {
	    $url = $_[$i+1];
	    $text = $_[$i];
	    next if &wbDeniedURL($User,$url);
	    $text = 'all' if $text eq '';
	    if ($url) {
		print "<A CLASS=SS HREF=\"$url\">$text</A><BR>\n";
	    } else {
		print "$text<BR>\n";
	    }
	}
	print "</FONT></TD></TR></TABLE>\n\n";
}

# --- title of a cell

sub printMenuTitle {

	local ($text,$url) = @_;

	print "<TABLE WIDTH=100% BORDER=0 CELLSPACING=0><TR VALIGN=MIDDLE><TD CLASS=MENUT>\n";
	if ($url) {
	    print "<A HREF=\"$url\"><B>$text</B></A>:\n";
	} else {
	    print "<B>$text:</B>\n";
	}
	print "</TD></TR></TABLE>\n";
}

sub wbBadPass {
	print <<EOM ; #UK
<H3 CLASS=ERROR>
Password does not match the password saved with the information.
You are not allowed to conclude this operation.
</H3>
EOM

}
	
# return convert %CGI values to %rec

sub wbCgiToRec {

	undef %rec;
	undef @recFiles;

#print join ('<BR>',keys(%CGI));

	foreach $field (keys(%WBF)) {
	    # print "$field = $CGI{$field}<BR>";

	    # userFile-old stores the old file name in editing USERFILE typed fields
	    
	    if ($CGI{"$field-old"} && ! $CGI{$field}) {
		#print "not field";
		$rec{$field} = $CGI{"$field-old"};
	    }

	    # skip those containing spaces only

	    next if $CGI{$field} =~ m/^\s*$/;

	    # the rest

	    if ($WBF{$field,type} eq 'DATE') {
		$y=$field."_year";
		$m=$field."_month";
		$rec{$field}="$CGI{$y}/$CGI{$m}/$CGI{$field}";
	    } elsif ($WBF{$field,type} eq 'USERFILE' || $WBF{$field,type} eq 'IMAGE') {
 		$rec{$field} = &wbUserFileSave($field);
#print $rec{$field};
		push (@recFiles,$rec{$field});	# tmp files
	    } else {
	        # print "set $field<BR>";
	        $rec{$field} = $CGI{$field};
	    } 
        }
}

sub wbCollate {

	return ('','') unless $WBB{intlCollate};
	local ($x,$c,$rest,$from,$to);

	@x = split(/\s/,$WBB{intlCollate});
	foreach $x (@x) {
	    $c = substr($x,0,1);
	    $rest = substr($x,1);
	    $tr{$c}=$rest;
	}

	$from = $to = '';
	
	$acTo=97;
	for ($ac=97; $ac<=122; $ac++) {
	    $c = pack('c',$ac);

	    # print STDOUT "$ac -> $acTo <BR>\n";

	    $from .= $c;
	    $to .= pack('c',$acTo++);

	    if ($rest=$tr{$c}) {
		for ($i=0;$i<length($rest);$i++) {
		    $s = substr($rest,$i,1);
	            # print STDOUT "$s => $acTo <BR>\n";
		    $from .= $s;
		    $to .= pack('c',$acTo++);
		}
	    }
	}

	return ($from,$to);
}

#
# create cookie headers for sticky values
#

sub wbCookieCGI {

	local ($out,$v,$stick);

	$out = '';

	foreach $x (keys(%CGI)) {
	    next if ($stick = $WBF{$x,sticky}) eq '';

	    if ($stick =~ m|/|) {
		$stick="path=$stick;";
	    } else {
		$stick='';
	    }
	    $v = &htEscape($CGI{$x});
	    next if $v eq '';		# make sure all cookies have values

	    # $v =~ s|\"|\\\"|g;	# escape quotes, hope \n are ok

	    $out .= "Set-Cookie: $x=$v; $stick expires=Wed, 31-Dec-99 23:59:59 GMT\n";
	}

	return $out;
}

#
# NT does not have crypt funtion
#

sub wbCryptPasswd {

    local ($what) =  @_;

    $seed = 'wb' . substr($what,0,2);

    unless ($NO_CRYPT) {
	return crypt($what,$seed);
    } else {
	return $what;
    }
}

sub glob {

	$_ = $_[0];
	s/\./\\\./g;
	s/\*/\.\*/g;
	# print "--- $_ ----\n";
	return &wbDir($_);
}

# get files with pattern $patt younger than $then
sub wbDir {

	local ($patt,$then) = @_;
	local (@x,@y,@xx,$ddir);

	if ($patt =~ m|/|) {
	    $patt =~ m|(.+)/([^/]+)$|;
	    $dir = $1;
	    $patt = $2;
	} else {
	    $dir = '.';
	}

	opendir(D,$dir);
	@x = readdir(D);
	closedir(D);
	@y = grep (/$patt/,@x);

	if ($then > 0) {
	    undef @x;
	    foreach $_ (@y) {
		@xx = stat($_);
		next if $xx[9] < $then;
		push (@x,$_);
	    }
	    return @x;
	} else {
	    return @y;
	}
}

# cache files are in _cache subdir    ... these are not pages but help speed up
#				      some functions

sub wbExpired {

	local ($file,$dataDir,$exp) = @_;
	local ($now, @x, @y);

	$exp = $WBB{cacheExpire} if $exp eq '';
	$exp = 0 if $exp eq '';
	$dataDir = $WBB{dataDir} if $dataDir eq '';

	return 1 if ! -e $file;

	@x = stat($file);

	if ($NO_DIRTIMES) {
	    if (! (-e "$dataDir/_cache/modtime.dir")) {
		open (h,">$dataDir/_cache/modtime.dir");
		print h ' ';
		close(h);
	    }
	    @y = stat("$dataDir/_cache/modtime.dir");
	} else {
	    @y = stat($dataDir);
	}

	if (($y[9] - $x[9]) > $exp*3600) { 
	    return 1;
	} else {
	    return 0;
	}
}	

sub wbDatabaseChanged {
	# win32 only

	local ($x);

	if ($WBB{'afterTableModify'} ne '') {
	    eval $WBB{'afterTableModify'};
	}

	return unless $NO_DIRTIMES;

	$x = "$WBB{dataDir}/_cache/modtime.dir";

	# no utime on NT either !

	open (hhh,">$x") || &wbFail ("Can't open $x");
	print hhh "This file's date is set to when the dataDir was last changed!";
	close(hhh);
}


sub wbExport {

	local ($sort,$format)=@_;
	print "Content-type: text/plain\n\n"; ### unless $HTMLFILE;

	# BUG ... if called from command line $HTMLFILE will be
	# set and these lines will not be printed ... but they
	# are expected by the routine that uses the stuff

	%saveHidden = %Hidden;
	undef %Hidden;

	do wbSortFields();
	@savePF = @PFields;
	push (@PFields,'_at');	# must be last!
	$PFields[$#PFields-1]='_password';
	do wbList($sort,$format);

	print &formatFoundHeader($format);
	foreach $x (@list) {
	    print $print{$x};
	    print "\n";
	}
	print &formatFoundFooter($format);

	%Hidden = %saveHidden;
	@PFields=@savePF;
}

sub wbFail {
    
    local ($title,$more) = @_;
    ($package,$filename,$line) = caller;

    $more = <<EOM;
<P>Cannot continue because of an error in $filename in line $line.
<P><B>$more</B>
<P>Please report this to the manager of this database: $WBB{managerEmail}
EOM

    do wbError("FATAL ERROR: $title",$more,$caller);
} 


sub wbError {

    local ($title,$message,$caller) = @_;
    
    select(STDOUT);

    if (! $HtmlHeaderPrinted ) {
	do printHead("");
    }

    $back = "Go back";

    print <<EOM;
<CENTER> 
<TABLE WIDTH=80% HEIGHT=10% ALIGN=CENTER BORDER=0><TR><TD></TD></TR></TABLE>
<TABLE CLASS=ERROR WIDTH=80% HEIGHT=80% ALIGN=CENTER BORDER=3>
<TR>
<TD ALIGN=CENTER>
<H1>$title</H1>
<P>$message
<P>$caller
<P>
<FORM NAME="buttonbar">
<INPUT TYPE="button" VALUE="$back" onClick="history.go(-1)">
</FORM>

</TR>
</TD>
</TABLE>
</CENTER>
EOM

    do printFoot();
    do wodaExit();
} 


sub wbFixId {
	local ($id) = @_;
	local ($lcFrom, $lcTo, $asFrom, $asTo);

	($lcFrom,$lcTo) = split(/ /,$WBB{intlLower});
	($asFrom,$asTo) = split(/ /,$WBB{intlAscii});

	if ($lcFrom ne '') {
	    $_ = $id;
	    eval "tr/$lcFrom/$lcTo/";
	    eval "tr/$asFrom/$asTo/" if $asFrom;
	    $id=$_;
	} else {
	    $id =~ tr|šðèæžŠÐÈÆŽ|sdcczSDCCZ|;
	}

	$id =~ tr/[A-Z]/[a-z]/;
	$id =~ tr| /\t|_|;
	$id =~ tr/()<>,;|"${}:/_/;
	$id =~ tr/[\200-\377]/_/;
	
	return $id;
}

sub cgiSetHelp {

	$help = $CGI{help};
	$referer = $CGI{referer};

	$COOKIE{_conf} =~ s/:NOHELP//;
	$COOKIE{_conf} =~ s/:HELP//;

	if ($help eq 'on') {
	    $COOKIE{_conf} .= ':HELP';
	} else {
	    $COOKIE{_conf} .= ':NOHELP';
	}

	$cookie = &htFormatCookie('_conf',$COOKIE{_conf});

	if ($referer) {
	    do printLocation($referer,$cookie);
	} else {
	    do printMiniHead("Set help $help",$cookie);
	    if ($JS >= 1) {
	    	print <<EOM; #UK
<P> You can now
<FORM>
<INPUT TYPE=BUTTON VALUE="go back" onClick="history.go(-1);">
</FORM>
<P>and reload that page.
EOM
	    } else {
	    	print <<EOM; #UK
<P> Please go back and reload for the changes to take effect.
EOM

	    }
	}

	$NOFOOT=1;
}


# return all between <FORM> tags
# use data in %rec as default values

sub wbForm {
	local ($out,$l);

	if ($COOKIE{_conf} =~ m/:NOHELP/) {
	    $Help = '';
	} else {
	    $Help = 1;
	}

$js = <<EOM;
<SCRIPT LANGUAGE="JavaScript"><!--

// check all or none of the checkboxes
function allBoxes(name,n) {
    for (var i=0; i<document.forms[0].elements[name].length; i++) document.forms[0].elements[name][i].checked=n
}

// validate form element if it is a regular expression
function validText(name,expression,message) {

    myRe = expression;
    if (myRe.test(name.value)) {
	return
    } else {
	alert(message)
    }
}	


// --></SCRIPT>
EOM

	$out = '';
	$out = $js if $JS;

	$help = "Help"; #UK
	$helpOff = "Show less help"; #UK
	$helpOn = "Show more help"; #UK
	$helpAll = "Display manual"; #UK

	$out .= "<TABLE CLASS=FORM><TR><TD><TABLE CLASS=FORM>\n";
	$out .= "<TR VALIGN=TOP><TH ALIGN=RIGHT></TH>";
	$referer = $Referer;
	if ($Help) {
	    $out .= <<EOM;
<TD><A HREF=$SCRIPT/SetHelp?help=off&$referer>$helpOff</A>
EOM
	} else {
	    $out .= <<EOM;
<TD><A HREF=$SCRIPT/SetHelp?help=on&$referer>$helpOn</A>
EOM
	}

	$out .= <<EOM;
| <A HREF="$SCRIPT/DisplayStructure" TARGET="woda_help">$helpAll</A></TD></TR>
EOM

	do wbSortFields();
	foreach $field (@Fields) {
# print "$field xxxxxxxxxxxx<BR>\n";
	    # skip extra fields
	    # next if $rec{$field} eq "";
	    do wbFormField();
	}

	    $x = 'Password:'; #UK
	    $out .= <<EOM ;
<TR VALIGN=TOP>
<TH ALIGN=RIGHT>$x</TH><TD>
EOM

	if (! &isOwner() || &isLoginTable()) {

	    if ($Help) {
	    	$out .= <<EOM; #UK
If you type a password,
only users that do know the password will
be allowed to delete or edit this record.
<BR>
EOM
	    }

	    if (&isLoginTable()) {
	    	$out .= <<EOM; #UK
This password will also be used
for logging in into this application.
<BR>
EOM
	    }


	    $x = 'again'; #UK
	    $out .= <<EOM;
<INPUT TYPE=PASSWORD NAME=\"_password\" SIZE=10 VALUE=$CGI{'_dPassword'}>
$x
<INPUT TYPE=PASSWORD NAME=\"_password1\" SIZE=10 VALUE=$CGI{'_dPassword'}>
EOM

	} else {

	    $out .= <<EOM; #UK
Only user $User is allowed to edit this record!
EOM

	}

	$out .= "</TD></TR></TABLE></TABLE>\n";

	# print length($out);
	return $out;
}

sub wbFormField {

	$after = '<BR>';

	return unless $Group =~ /admin|$WBF{$field,modifies}/; # || $WBF{$field,modifies} eq '' ;

	if ($WBF{$field,type} eq 'BREAK') {
	    $out .= "<TR><TD COLSPAN=2><H3><CENTER><HR>$WBF{$field}</CENTER></H3></TD></TR>\n";
	    return;
	}

	return if $WBF{$field,type} eq 'COMPUTE';
	$hidden=0;
	$hidden=1 if $WBF{$field,typePar} =~ m/HIDDEN/i;

	$niceField = $WBF{$field,head};
	unless ($niceField) {
	    $niceField = $field;
	    $niceField =~ s/([A-Z]+)/ $1/g;
	    $niceField =~ tr/[A-Z]/[a-z]/;
	}
	$niceField = "$niceField:";
	$niceField = '' if $hidden;

	$validIfText = "valid if" ; #UK

	# begin ...

	$nok = '';
	$nok = "<IMG SRC=$ICONURL/del.gif ALT=Error $ICONPAR>" if $err{$field} == 1;

	if (! $continue) {
	    $out .= "<TR VALIGN=TOP>\n";
	    $out .= "<TH ALIGN=RIGHT>$niceField$nok</TH>\n<TD>";
	    $out .= "$WBF{$field,p}" if $Help && !$hidden;;
	}

	$alert='';
	if ( $WBF{$field,cond} ) {
	    $alert = $WBF{$field,cond};
	    $out .= " <SMALL><I>($WBF{$field,cond})</I></SMALL>\n" if $Help && !$continue && !$hidden;
	} else {
	    $alert = "$validIfText: $WBF{$field}" if $WBF{$field} ne "1;";
	    $out .= " <SMALL>($validIfText: <TT>$WBF{$field}</TT>)</SMALL>" if $Help && $WBF{$field} ne "1;" && !$continue && !$hidden;
	}

	if ( $JS>=1.2 && $WBF{$field} =~ m|^m(/.*/[a-z]*$)| ) {
	    $onChange = <<EOM;
onChange="validText(this,$1,'$field: $alert')"
EOM
	} else {
	    $onChange = '';
	}

	if ($JS && $status !~ m/<\(/ ) {			# weed out HTML !
	    $status = "$field: $WBF{$field,p} ... $alert";
	    $status =~ s/\n/ /g;
	    $status =~ tr/"'<>/    /;
	    $onClick = "onClick =\"self.status='$status'\"\n";
	    $onFocus = "onFocus =\"self.status='$status'\"\n";
	    $onBlur = "onBlur   =\"self.status='WODA!'\"\n";
	} else {
	    $status = $onClick = $onFocus = $onBlur = '';
	}

	$out .= "<BR>\n" if $Help && ($WBF{$field} ne "1;" || $WBF{$field,p});
	$default = $rec{$field};
	$default = $CGI{$field} if $default eq "";
	$default = $COOKIE{$field} if $default eq "" && $WBF{$field,sticky};
	$default = $WBF{$field,d} if $default eq "";
	$default = eval $default if $default =~ m/^&|;\n/;
	$default = &htQuote($default);
	$typePar = $WBF{$field,typePar};

	if ($typePar =~ s/CONTINUE//) {
	    $continue=1;
	} else {
	    $continue=0;
	}
	
	if ($WBF{$field,type} =~ m/^TEXTAREA|HTMLAREA|LIST$/) {
	    $typePar = "ROWS=8 COLS=50" if $typePar eq '';
	    $out .= <<EOM;
$INPUTON<TEXTAREA NAME="$field" WRAP="VIRTUAL" $typePar 
$onChange $onFocus $onBlur 
>$default</TEXTAREA>$INPUTOFF
EOM

	} elsif ($WBF{$field,type} =~ m/^OPTION$|^LINKOPTION$/ ) {

	    @options = &wbParseOptions($field);
	    # optionText also set
	    $no=0;

	    $default = "\n$default\n";

	    if ($#options > 0) {
	        $cols = int(70./(length(join('1234567',@options))/$#options));
	    } else {
	        $cols = 1 if $#options<3;
	    }
	    undef @x;

	    $typePar = 'RADIO' if ($typePar eq '' && $#options<2);

	    # as checkbox
	    if ($typePar =~ m/CHECKBOX/) {
	        foreach $o (@options) {
		    $okey = "($o)";
		    $okey = "$o" if $optionText[$no] eq '';
		    $t="$optionText[$no++] <SMALL>$okey</SMALL>";

		    $reo = &regexpEsc($o);

	            if ($default =~ /\n$reo\n/ ) {
		    	push (@x,"<INPUT TYPE=CHECKBOX NAME=$field VALUE=\"$o\" CHECKED $onClick>$t\n");
	            } else {
	            	push (@x,"<INPUT TYPE=CHECKBOX NAME=$field VALUE=\"$o\" $onClick>$t\n");
	            }
		}
		$alltext = "check all"; #UK
		$nonetext = "check none"; #UK
		$allhtm =<<EOM;
<A HREF=javascript:allBoxes('$field',1)>
<IMG SRC=$ICONURL/check.gif $ICONPAR ALT="$alltext">
</A>
<A HREF=javascript:allBoxes('$field',0)>
<IMG SRC=$ICONURL/uncheck.gif $ICONPAR ALT="$nonetext">
</A>
EOM
	        push (@x, $allhtm) if $JS;
		$out .= &formatColumns($cols,@x);
		$after = '';

	    # as radio
	    } elsif ($typePar =~ m/RADIO/) {
	        foreach $o (@options) {
		    $okey = "($o)";
		    $okey = "$o" if $optionText[$no] eq '';
		    $t="$optionText[$no++] <SMALL>$okey</SMALL>";
		    $reo = &regexpEsc($o);
	            if ($default =~ /\n$reo\n/ ) {
		    	push (@x,"<INPUT TYPE=RADIO NAME=$field VALUE=\"$o\" CHECKED $onClick>$t\n");
	            } else {
	            	push (@x,"<INPUT TYPE=RADIO NAME=$field VALUE=\"$o\" $onClick>$t\n");
	            }
		}
		$out .= &formatColumns($cols,@x);
		$after = '';

	    # as pulldowns
	    } else {
    		$out .= "<SELECT NAME=\"$field\" $typePar $onClick>\n";
	    	foreach $o (@options) {
		    $okey = "($o)";
		    $okey = "$o" if $optionText[$no] eq '';
		    $t="$optionText[$no++] $okey";
		    $reo = &regexpEsc($o);
	            if ($default =~ /\n$reo\n/ ) {
		    	$out .= "<OPTION SELECTED VALUE=\"$o\">$t\n";
	            } else {
	            	$out .= "<OPTION VALUE=\"$o\">$t\n";
	            }
	        }
	        $out .= "</SELECT>";
	    }


        } elsif ($WBF{$field,type} eq "FILE") {
	    $typePar = "SIZE=20";
 	    $out .= "$INPUTON<INPUT TYPE=TEXT NAME=\"$field\" VALUE=\"$default\" $typePar $onFocus $onBlur>$INPUTOFF\n";

        } elsif ($WBF{$field,type} eq "USERFILE" || $WBF{$field,type} eq "IMAGE") {

	    $WBB{hasUserFile} = 1;

	    $typePar = "SIZE=30" if ! $typePar;
	    $help = "enter name of a file on <I>your</I> computer which contains this data (only works with Netscape Navigator 2+ or Microsoft Explorer 4+)" ; #UK
 	    $out .= "<FONT FACE=Courier><INPUT $onFocus $onBlur TYPE=\"FILE\" NAME=\"$field\" $typePar></FONT><BR><SMALL>$help</SMALL>\n";
	    if ($default) {
		$keep = "to delete file: erase text in the lower box above" ; #UK
		$out .= "<BR><FONT FACE=Courier><INPUT NAME=\"$field-old\" VALUE=\"$default\" $typePar></FONT><BR><SMALL>$keep</SMALL>\n";
	    }

        } elsif ($WBF{$field,type} eq "EMAIL") {
	    $typePar = "SIZE=40" if ! $typePar;
	    $default = "$ENV{REMOTE_USER}\@$ENV{REMOTE_HOST}" if ! $default;
 	    $out .= "$INPUTON<INPUT $onFocus $onBlur TYPE=TEXT NAME=\"$field\" VALUE=\"$default\" $typePar $onChange>$INPUTOFF\n";

        } elsif ($WBF{$field,type} eq "DATE") {
	    ($y,$m,$d) = split(/\//,$default);
	    $ny = $field . '_year';
	    $nm = $field . '_month';	
	    $help = "year/month/day" ; #UK
	    $out .= <<EOM;
$INPUTON<INPUT NAME="$ny" VALUE="$y" SIZE=4 $onFocus $onBlur
>/<INPUT NAME="$nm" VALUE="$m" SIZE=2 $onFocus $onBlur
>/<INPUT NAME="$field" VALUE="$d" SIZE=2 $onFocus $onBlur>$INPUTOFF $help
EOM

	} else {
  	    $typePar = "SIZE=50" if $typePar eq "";
	    if ($typePar =~ m/HIDDEN/) {
		$t = 'HIDDEN';
	    } else {
		$t = 'TEXT';
	    }
	    $out .= "$INPUTON<INPUT TYPE=$t NAME=\"$field\" VALUE=\"$default\" $typePar $onChange $onFocus $onBlur>$INPUTOFF\n";

	}

	# help part

        if (! $continue) {	
	    if ($Help && $WBF{$field,help} && !$hidden) {
		$out .= "$after<SMALL>$WBF{$field,help}</SMALL>";
	    }
	    $out .= "</TD></TR>\n";
	}
}

# parses the $WBF{?,options} value
# returns list of options and set @optionText to text values

sub wbParseOptions {

	    local ($field) = @_;
	    local (@wbp,$i,$o,$t,$alias,$fields);
	    undef (@optionText);

	    if ($WBF{$field,type} eq "LINKOPTION") {
		if ($WBF{$field,into} =~ /^&/) {
		    $t = eval ($WBF{$field,into});
		    @wbp = split (/\n/,$t);
		} else {
		    return &wbIds($WBF{$field,into});
		}
	    } elsif (! ($WBF{$field,options} =~ /\|/)) {
		@wbp = split (/\n/,$WBF{$field,options}); # /n delimited
	    } else {
	        return split (/\|/,$WBF{$field,options}); # | delimited
	    }

	    for ($i=0;$i<=$#wbp;$i++) {
		($o,$t) = split(/\t/,$wbp[$i],2);
		$wbp[$i]=$o;
		$optionText[$i]=$t;
		$wbp[$i] =~ s/\s+$//;
	    }
	    return @wbp;
}

# increment the access count and return number of accesses
# access.txt:
# 	number of accesses
#	since
#	last time maintenance was run
#	at command is failing

sub wbAccessCount {

    local (@data,$file,$job);

    $file = "$WBB{dataDir}/_cache/access3.txt";

    unless (-e $file) {
        open (access,">$file");
	print access "0\n";
	print access time() . "\n";
	close (access);
    }

    open (access,"+<$file");
    @data=<access>;		# no locking !!!, newlines included !
    chop (@data);
    $data[0]++;

    $freq = $WBB{maintenancePeriod} || 0;	# automatic maintenance off !!!
    $freq = $freq*3600;
    $t = time - $data[2];
    if (!$CMDLINE && $freq && $data[3] ne '1' && (time - $data[2]) > $freq) {
	$job = &wbAtdo();
	if ($?) {
	    $data[3]=1;
	} else {
	    $data[2]=time;
	}
    }

    seek (access,0,0);
    print access join("\n",@data);
    print access "\n";
    close(access);

    return $data[0];
}

sub wbAccessData {

    local (@data,$file);

    $file = "$WBB{dataDir}/_cache/access3.txt";
    open (access,"<$file");
    @data=<access>;		# no locking !!!
    close(access);

    return (@data);
}




sub wbGetAd {

    local ($adFile) = @_[0];
    local ($x,$img,$url,$text);
    local (@ads);

    open (ad,$adFile) || return ("","","");
    @ads = <ad>;
    close (ad);

    $x = rand() * ($#ads+0.999);
    $x = int ($x);
    return split (/\t/,$ads[$x],3);
}

# greps @records into @list using @sWords, @aWords, @nWords and 
# sets @list

sub wbGrepRecords {

	local ($time) = @_;
	undef (@list);

	if ($time) {			# time zadnja zadeva !
	   foreach $_ (@records) {
		m/([0-9]*)$/;
		push (@list,$_) if $1>$time;
	   }
	   $Log .= "Processed time with $time ... $#list\n"; 
	} else {
	   @list = @records;
	}


	# remove nots
	foreach $word (@nWords) {
	    next if $word eq '';
	    $patt = &wordBound($word);
	    @list = grep(!/$patt/i,@list);
	    $Log .= "Perl grep with !/$patt/i ... $#list\n"; 
	}

	# remove and
	foreach $word (@aWords) {
	    next if $word eq '';
	    $patt = &wordBound($word);
	    @list = grep(/$patt/i,@list);
	    $Log .= "Perl grep with /$patt/i ... $#list\n"; 
	}

	# extract Sex stuff
	if ($sExpression) {
	    $*=1;
	    undef @y;
	    foreach $row (@list) {
		do wbTab2Rec($row);
		push (@y,$row) if eval $sExpression;
	    }
	    $*=0;
	    @list = @y;
	    $Log .= "Perl evaluation of $sExpression  ... $#list\n";
	}

	# count orwords
	undef @y;
	foreach $word (@sWords) {
	    next if $word eq '';
	    $patt = &wordBound($word);
	    @x = grep(/$patt/i,@list);
	    push (@y,@x);
	    $Log .= "Perl grep with /$patt/i ... $#x/$#list\n"; 
	}

	# how much stuff was contributed by filter

	$nots = $#nWords - $filterNots + 1;
	$ands = $#aWords - $filterAnds + 1;

	if ($nots || $ands || $time) {
	    push (@list,@y);
	} elsif (@sWords) {
	    @list = @y;
	} else {
	    # anything goes
	}
}

#
# search by default means whole words
# car ... car* matches cardinal
#

sub wordBound {
	local ($word) = @_;

	$word =~ s/(\W)/\\$1/g;	# escape special characters
	$word =~ s/\\\*/\.\*/g;	# lju\*ana into lju.*ana
	$word =~ s/^(\w)/\\b$1/;# prepend /b if it starts with a character
	$word =~ s/(\w)$/$1\\b/;# append /b if it ends with a character

	return $word;
}


# wbTables() creates TBL array based on WBB{tables??}
# wbTables($op,$alias) returns $TBL{$op,$alias}

sub wbTables {

	local ($op,$alias) = @_;
	local (@x,$x,$al,$dir,$def,$_);

	if ( ! defined (%TBL)) {
	    @x = split (/\n/,$WBB{tables});
	    foreach $_ (@x) {
		($al,$def,$dir)=split(/\s+/,$_,3);
		$TBL{'DIR',$al} = $dir;
		$TBL{'DEF',$al} = $def;
	    }	
	}

	if ($op) {
	    return $TBL{$op,$alias};
	}

	return '';
}

# return an array of id's of a database in directory $dir
# dir may also be interpreted as an ALIAS from WBB{tables}

sub wbIds {
	local ($dir) = @_;
	local (@x,@y);

	undef @y;

	# relative path name or xxx an alias ????

	if ($dir =~ m/^\w+$/) {		# words ... alias
	    $dir = &wbTables('DIR',$dir);
	} elsif (! $dir =~ m|^/|) {	# relative path
	    $dir = $WBB{dataDir} . '/' . $dir;
	} else {
	    # absolute path
	}

	# cached ?

	if ($IDCache{$dir} ne "") {
	    return split (/\|/,$IDCache{$dir});

	} else {
	    
	    @x = &glob("$dir/*.rec");

	    foreach $x (@x) {
		$x =~ m|([^/]*).rec$|;		# extract the key		
		push (@y,$1);
	    }

	    @x = sort(@y);

	    $x = join ('|',@x);
	    $IDCache{$dir} = $x;

	    return @x;
	}
}

# set default sort expression to "$rec{field1}"

sub wbList {
	
	local ($sort,$format) = @_;

	$sort = 'DEFAULT' unless $sort;
	$format = 'DEFAULT' unless $format;

	undef @list;
	undef @l;
	undef @records;
	undef %hits;
	undef %sort;
	undef %data;
	undef %print;

	do wbSortFields();
	$now = time;

	# set $wbb{sort;DEFAULT} unless missing

	if ($WBB{'sort;DEFAULT'} eq '') {
	    $WBB{'sort;DEFAULT'} = '"$rec{' . "'" . $Fields[0] . "'" . '}"';
	}

	@files = &wbDir('\.rec$');

	($coFrom,$coTo) = &wbCollate();
	($lcFrom,$lcTo) = split(/ /,$WBB{intlLower});
	undef $coEval;
	undef $lcEval;
	$coEval = "tr/$coFrom/$coTo/" if $coFrom;
	$lcEval = "tr/$lcFrom/$lcTo/" if $lcFrom;

	# print STDOUT "<TT>$coFrom<BR>$coTo<P></TT>\n";

	foreach $file (@files) {

	    # remove zero length files 

	    if (-s $file == 0) {
		unlink ($file);
		next;
	    }

	    do wbParseFile($file,1);
	    $file =~ m/(.*).rec$/;
	    $id = $1;

	    if ($sort eq 'TIME') {
		@t = stat($file);
		$sort{$id} = $t[9];
	    } elsif ($WBB{"sort;$sort"}) {
 	    	$x = $WBB{"sort;$sort"};
		$_ = eval $x;
		s/^\s*//;			# ignore leading spaces!
		eval $lcEval if $lcEval;	# do case lowering & other equivalences
		tr/[A-Z]/[a-z]/;		# lower case
		eval $coEval if $coEval;	# different collate
		$sort{$id}=$_;
	    } else {
		$sort{$id}=eval $sort;
	    }

	    # --- use the collate stuff

	    $x = $sort{$id};

	    $sort{$id} =~ tr/$trFrom/$trTo/ if $trFrom;

	    # print STDOUT "$x<BR>$sort{$id}<P>\n";

	    # --- create the %print array (2/3 time)

	    $print{$id} = &formatFoundRow ($id,$format);

	}

	# sort it 

	if ($sort eq 'TIME') {
            @list = sort { $sort{$b} <=> $sort{$a} } keys(%print);
	} else {
	    @list = sort { $sort{$a} cmp $sort{$b} } keys(%print);
	}

	$allHits = $#list + 1 if ! $allHits;
	return $allHits;
}

sub wbMoveFile {
    local ($from,$to) = @_;

    return unless -e $from;
    return if $to eq "";

    if ($MV) {
        return `$MV "$from" "$to"`;
    } else {

        open (x,$from);
	binmode(x);
        @x = <x>;
        close (x);

        unlink $from;

        open (x,">$to");
	binmode(x);
        print x @x;
        close (x);
    }
}
	
# -----------------------------------------------------------------------
# fill %rec array with values from file
#

sub wbParseFile {          
	local ($inFile,$ignoreErrors) = @_;
	local ($err,$id,$_,$i,@x);
	undef %rec;
	undef @x;

	$_ = $inFile;
	m|([^/]+)\.rec$|;
	$id = $1;

	open (h,"<$inFile") || do wbFail("Can't open record in file $inFile\n");
	binmode(h);

	# --- binary format 

	$x = getc(h);

	if ($x eq "\x0A") {	# vrstice so CR only
	    $/="\x0A";
	    @x = <h>;
	    close h;
	    for ($i=0; $i<=$#x; $i++) {
		chop($x[$i]);	#newline
	        $x[$i] =~ tr/\034/\012/;
	    }
	    %rec = @x;		
	    $rec{_id}=$id;

	    return "" if $ignoreErrors;
	    $err = &wbTestRec();
	    return $err;
	} elsif ($x eq "\x0D") {	# vrstice so CR-LF
	    getc(h);		#ctrl-m
	    $/="\x0A";
	    @x = <h>;
	    close h;
	    for ($i=0; $i<=$#x; $i++) {
		chop($x[$i]);	#newline
		chop($x[$i]);	#ctrl-m
	        $x[$i] =~ tr/\034/\012/;
	    }
	    %rec = @x;		
	    $rec{_id}=$id;

	    return "" if $ignoreErrors;
	    $err = &wbTestRec();
	    return $err;
	}

	# --- readable format

	$rec{_id}=$id;

	if ($weCareAboutLineBreakValue) {

	    # what kind of line breaks do we have here ?

	    $_=<h>;
	    if (m/\015%/) {
	        $/="\015%";
	    } else {
	        $/="\n%";
	    }
	    $break=$/;		# perl5!!!

	    close h;

	    # parse it now

	    open (h,$inFile);

        } else {

    	    $/ = "\n%";
	    $break = $/;

        }

	$inFile =~ m|([^/]*)\.ad.$|;
	$id=$1;
	# getc h;		# eat % on first line
        while (<h>) {
		s/$break$//;			# chop off the break

                ($tag,$value)=split(/\:/,$_,2);
		next if $tag =~ m/^\%/;		# comment
		$value =~ s/\015\n/\n/g;         # ctrl-m to newline
		$value =~ s/\015/\n/g;          # ctrl-m to newline
		# $value =~ s/\n/ /;		# newline to space
                # $value =~ s/[\s]+/ /g;	# multiple space -> 1 space
		$value =~ s/^\s*//;		# leading space
		$value =~ s/\s*$//;		# trailing space 
                #$tag =~ tr/[A-Z]/[a-z]/;	# igonore case

		if ($WBF{$tag,type} eq "TEXTAREA") {
		    $value =~ s/\n\t/\n/g;
	        }

                if ($x = $WBF{$tag} || $tag =~ m/^_/) {
		    $rec{$tag}=$value;
		} else {
		    $err .= "Field $tag is not valid!\n" ; #UK
		}
	}

	close h;
	$/ = "\n";

	unless ($ignoreErrors) { # shall we test it
	    $err .= &wbTestRec();
	    return $err;
	}

	return "";
}

#
#
# search section
#
#

# set sWords[], aWords[], nWords[] arrays
# set Sex (search expression)

sub wbParseSearch {

	local ($search) = @_;
	($search,$sExpression) = split (/\{/,$search,2);
	if ($sExpression) {
	    $_ = "{$sExpression";
	    if ( m/\w\s*\(|&|`|;|system|exec|spawn/ ) {
		do wbFail("Invalid character in search expression"); 
	    }
	    s/\{/\$rec\{/g;
	    s/ and / && /g;
	    s/ or / || /g;
	    s/ not / ! /g;

	    $sExpression = $_;
	}

	@words = split (/ /,$search);
	$s=0;
	$n=0;
	$a=0;
	$dWord = '';
	undef @sWords;
	undef @aWords;
	undef @nWords;

	while (@words) {
	    $dWord .= shift(@words);
	    if (($dWord =~ tr/"/"/) % 2) {
		$dWord .= ' ';
		next;
	    }

	    # +email:ziga

	    if ($dWord =~ m/\:/) {
		($f,$w)=split(/\:/,$dWord,2);
		if ($f =~ m/"/) {
		    #   "sdfsf:adasds" ... not special !
		} else {
		    $we = $w;
	    	    $we =~ s/"//g;
		    $pwe = &wordBound($we);
		    ($s,$f) =~ m/^([-+=\/]{0,1})(.*)$/;
		    $s = $1 || '+';
		    $f = $2;
		    if ( $IsField{$f} ) {
		    	if ($sExpression eq '') {
			    $sExpression = '1';
		    	}
		    	if ($s eq '-') {
			    $sExpression .= " && ! (\$rec{'$f'} =~ m/$pwe/i)";
		            $dWord = '';
			    next;
		    	}
		    	if ($s eq '+') {
			    $sExpression .= " && (\$rec{'$f'} =~ m/$pwe/i)";
		            $dWord = "+$w";
			    # process normally
		    	}
		    	if ($s eq '=') {
			    $sExpression .= " && (\$rec{'$f'} eq '$we')";
		            $dWord = "+$w";
			    # process normally
		        }
		    	if ($s eq '/') {
			    $sExpression .= " && (\"\\n\$rec{'$f'}\\n\" =~ m/\\n$we\\n/i)";
		            $dWord = "+$w";
			    # process normally
		        }
		    }
		}
	    }

	    $dWord =~ s/"//g;

	    if ($dWord =~ m/^\-(.*)/) {
	        $nWords[$n++]=$1;
            } elsif ($dWord =~ m/^\+(.*)/) {
		$aWords[$a++]=$1;
	    } else {
		$sWords[$s++]=$dWord;
	    }
	    $dWord = '';
	}

}

# read records into @records array and field names into @filedNames

sub wbReadRecords {
	local ($sort,$grepPatt) = @_;

	if ($GREP && $WBB{grepBigger} && $grepPatt ne '' && (-s "_cache/$sort.tbl" > $WBB{grepBigger})) { 
#print "USING GREP with '$grepPatt'\n";
   	    open (h,"_cache/$sort.tbl") || do wbFail("Open of $sort.tbl failed");
	    $records[0] = <h>;		# attn: newlines included !
	    $records[1] = <h>;		# attn: newlines included !
	    $records[2] = <h>;		# attn: newlines included !
	    close (h);
	    do wbReadRecordsFnames();
	    $grepPatt =~ s/"//g;	
	    $grepPatt =~ s/\*$//g;	 
	    $grepPatt =~ s/^\*//g;
	    $grepPatt =~ s/\*/\.\*/g;
	    if ($grepPatt =~ m/^\w*$/) {
		$sw = '-F';
	    } elsif ($grepPatt =~ m/\|/) {
		$sw = '-E';
	    } else {
		$sw = '';
	    }
	    $g = "$GREP -i $sw \"$grepPatt\" _cache/$sort.tbl |";
	    open (h,$g);
	    @records = <h>;
	    $Log .= "$g ... $#records\n";
	    close(h);

	} else {
            #print "NOT USING GREP !\n";
	    # brute force
   	    open (h,"_cache/$sort.tbl") || do wbFail("Open of $sort.tbl failed");
	    @records = <h>;		# attn: newlines included !
	    close (h);
	    $searchProc = "Reading all records from $sort.tbl\n";
	    do wbReadRecordsFnames();
	}
}

# sets fieldNames based on first 3 rows

sub wbReadRecordsFnames {

	if ($records[1] =~ m/^\n/) {
	    $x=shift(@records); # content type
	    $x=shift(@records); # blank
	}
	$x=shift(@records);
	chop($x);
	@fieldNames = split(/\t/,$x);
}

sub formatFieldName {

	local ($_) = @_;

	if ($WBF{$_,'head'}) {
	    return $WBF{$_,'head'};
	}

	s/([a-z])([A-Z])/$1 $2/g;
	tr/[A-Z]/[a-z]/; 
	
	return $_;

	# staro
	s/([A-Z])/ $1/g;
	s/([A-Z]) ([A-Z])/$1$2/;
	tr/[A-Z]/[a-z]/; 

	return $_;
}

# print rec in an HTML table or as defined in 'detail' format

sub wbRecHtml {
	local ($out,$value,$x,$th1,$th2);

	if ($WBB{detail} ne '' && $_[0] eq '') {
	    $out = eval $WBB{detail};
	    return $out;
	}

	# ($th1,$th2) = ("field","value") ; #UK

	$out .= <<EOM;
<TABLE CLASS=DETAIL BORDER=0 WIDTH=100%>

<TR>
<TH ALIGN=RIGHT VALIGN=TOP><I>$th1</I></TH>
<TH ALIGN=LEFT VALIGN=TOP><I>$th2</I></TH>
</TR>
EOM

	do wbSortFields();

	foreach $field (@Fields) {

	    # skip unseen

	    next if $Hidden{$field};

	    # banners

	    $value = &formatField($field);

	    if ($WBF{$field,type} eq 'BREAK') {
	        $out .= "<TR><TH> </TH><TH ALIGN=LEFT>$WBF{$field}</TH></TR>\n";
		next;
	    }

	    next unless $value;

	    $name = &formatFieldName($field); 

	    $out .= "<TR>\n<TH ALIGN=RIGHT VALIGN=TOP>$name</TH>\n<TD>$value</TD>\n</TR>\n\n";
	}

	# admin details

	$niceDate = &formatDate($rec{_at});
	$from = "Entered" ; #UK

	$out .= <<EOM unless $WBB{hideUnderscore} eq '1';
<TR>
<TD COLSPAN=2 ALIGN=RIGHT>
<FONT SIZE=2>
$from $rec{_from} $niceDate
</FONT></TD>
</TR>
EOM

	$out .= "</TABLE>\n";

	return $out;
}

#
# print %rec as plain text
#

sub wbRecPrint {

	if ($WBB{'ascii'}) {
	    return &formatAscRec();
	} else {
	    return &formatBinRec();
	}
}

# find records, returns @list of @ids and %print and %data
# see also wbList which lists all records !

sub wbSearch {

	# uses &PIC()

	$xxxxtime = time;

	local ($search,$then,$sort,$format,$first,$max) = @_;
	local ($now,$allHits);

	# --- hide some records from the search

	@x = split (/\n/,$WBB{filter});
	foreach $_ (@x) {
	    ($group,$filter) = split (/\s+/,$_,2);
	    if ($group eq $Group) {
		do wbParseSearch($filter);
		$filterAnds = $#aWords + 1;
		$filterNots = $#nWords + 1;
		$filterSex = $sExpression;
		$search .= " $filter";
		last;
	    }
	}

	# --- default format and sort

	$sort = 'DEFAULT' if $sort eq '';
	$format = 'DEFAULT' if $format eq '';

	# --- do we need to update the static file ---

	if ($WBB{"sort;$sort"} || $sort eq 'TIME' || $sort eq 'DEFAULT') {
	    local ($sort,$format)=($sort,$format);
	    do wbUpdateTbl($sort);
	}

	# max = max num of hits !

	undef @list;		# things to print out
	undef @records;		# records in .tbl format
	undef %hits;
	undef %sort;
	undef %data;
	undef %print;

	do wbSortFields();
	$now = time;

	# --- set the defaults

	$first = 0 if ! $first;
	$max = 99999999 if ! $max;		# adminExport !
	$last = $first+$max-1;

	do wbParseSearch($search);

	# --- build a list of matching records

	$grepPatt='';
	if ($GREP) { # prepare search pattern for GREP
	    if ($aWords[0] ne '') {
		$grepPatt = $aWords[0];
	    } elsif ($#sWords >= 0) {
		$grepPatt = join ('|',@sWords);
	    }
	}

	# --- cached searches

	$csearch = "records $search $then $sort";
	$csearch = "records $search $then $sort $Group" if $WBB{filter};
	$csearch = "_cache/" . &htEscape($csearch) . ".txt";
	if (! &wbExpired($csearch)) {
	    open (H,$csearch);
	    $x = <H>;
	    chop($x);
	    @fieldNames = split(/\t/,$x);
	    @list = <H>;
	    close(H);
	} else {
	    do wbReadRecords($sort,$grepPatt);	# read into RAM the presorted table
	    do wbGrepRecords($then);		# create @list, may have duplicates
						# because of sWords, uses time constraint
						# does all the filtering as well
	    if ($WBB{searchCache} && $#list >= 0 && ($search ne '' || $then ne '')) {
	        open (H,">$csearch");		
	        print H join("\t",@fieldNames) . "\n";
	        print H @list;
	        close(H);
	    }
	}

	# --- trim the list

	undef $allHits;

	if ($#sWords < 0) { # 0 search words, trim now, no extra sorting will be needed
	    $allHits = $#list+1;
	    do wbTrimList($first,$last);
	    $trimmed = 1;
	}

	# use the fact that alphatab is presorted !

#print "All matches $#list ...\n";

	$i=0;
#print $list[0];
	foreach $_ (@list) {
	    $i++;
	    ($id,$rest) = split(/\t/,$_,2);
   	    $sort{$id}=$i unless $sort{$id};	
	    $data{$id}=$_ unless $data{$id};
	    $hits{$id}++;
	}

	# xxx what if presort cannot be used ?
	# sort on hits + original order

	foreach $_ (keys(%data)) {
	    $sort{$_} += (100-$hits{$_})*10000;
	}

	@list = sort {$sort{$a} <=> $sort{$b}} keys(%hits);

#print "After sorting $#list ...\n";

	$allHits = $#list+1 unless $allHits;

	do wbTrimList ($first,$last) unless $trimmed;

	# printout

	@ids = @list;
	undef @list;

	if ($format ne 'NIL to get ast') {
	    $i=0;
	    foreach $id (@ids) {
		do wbTab2Rec($data{$id});
		$list[$i] = &formatFoundRow($id,$format);
		$i++;
	    }
	} else {
	    # @list will not be defined
	    # all else is there
	    # saves time !
	}

	return $allHits;
	# return @list in printout format, @ids, $data{id}
}

sub wbSearchForm {

    local ($prompt, $help, $verb, $size);

    $sstring=$_[0];

    $prompt = "Search for:" ; #UK
    $help = "Tip:"; #UK
    $help .= &formatSearchHelp();
    $help .= "... <A HREF=$SCRIPT/HelpSearch>all tips and help</A>.";  #UK
    $verb = "Search" ; #UK

    $size = length($sstring) || 20;
    $size = 20 if $size < 20;
    # $x =~ s/"/%22/g;

    return <<EOM;
<FORM ACTION=$SCRIPT/Search>
<TABLE CLASS=SEARCH BORDER=0 CELLSPACING=0><TR><TD>
$prompt
<BR><INPUT NAME=search SIZE=$size VALUE='$sstring'><INPUT TYPE=SUBMIT VALUE="$verb">
<BR><SMALL>$help</SMALL>
</TD></TR></TABLE>
</FORM>
EOM

}

sub wbHelps {

	$help = <<EOM;	#UK
Type <B>car vehicle automobile</B> to search for any of the words.
Type <B>"New York" car</B> to search for 'New York' or 'car'.
Type <B>new +car</B> to find only records which do contain 'car' and may contain word 'new'.
Type <B>-used car vehicle</B> to find only records which contain words 'car' or 'vehicle' but not 'used'.
Type <B>car*</B> to find 'car' and 'cardinal'.
Type <B>*car</B> to find 'vicar' and 'car'.
Type <B>*car*</B> to find 'vicar', 'cardinal' and 'car'.
Type <B>" car "</B> or "<B>\\scar\\s</B>" to find 'car' and not 'vicar' or 'cardinal'.
Type <B>+email:uni-lj</B> to search for 'uni-lj' in the email field only.
Type <B>-email:edu</B> to find records which do not have word 'edu' in the email field only.
Type <B>=lastName:Turk</B> to find records with lastName field exactly equal to Turk. 
Type <B>/lastName:Turk</B> to find records with one line of lastName field exactly equal to Turk. 
Type <B>{price} < 2000</B> to search for items with price field less than 2000.
EOM
	@helps = split(/\n/,$help);
}

sub formatSearchHelp {

	local (@helps,$help,$i);
	do wbHelps();
	$i = int(rand(6.99));
	return @helps[$i];
}

sub cgiHelpSearch {

	do printHead ("Search Tips");	#UK

	do wbHelps();
	print "<UL>\n";
	foreach $help (@helps) {
	    print "<LI>$help\n";
	}

	print <<EOM;	#UK
</UL><B><A HREF="$WBHelp#search">Detailed search help.</A></B>
EOM
}

# sets @Fields array which is a sorted array of all fields in the database
# sets %Hidden array based on permissions which lists hidden fields
# sets @PFields array which also includes _id, _at and _from
# sets %IsField to enable fast control of what is a field name and what is not
# does it only once

sub wbSortFields {

	return if defined @PFields;

	undef %Hidden;
	undef %IsField;
	undef @Fields;

	local ($x, $y);

	foreach $x (keys(%WBF)) {
	    # print "$x<BR>";
	    next if $x =~ m/$;/;

	    if ($y = $WBF{$x,'sees'}) {
		# print $y;
		unless ($Group =~ m/$y/ || $Group eq 'admin') {
		    $Hidden{$x} = 1;
		    # print "$x is hidden";
		}
	    }

	    push (@Fields,$x);
	    $IsField{$x}=1;
	}

	@Fields = sort { $WBF{$b,'srt'} <=> $WBF{$a,'srt'} } @Fields;
	@PFields = ('_id',@Fields,'_from','_at');

	return;
}
		
# needs @fieldNames as defined in wbReadRecords

sub wbTab2Rec {
	local ($row) = $_[0];
	local ($field,$i,$x,@x);

	$x = chop ($row);	# newline ?
	if ($x ne "\n") {
	   $row.=$x;
	}

	@x = split (/\t/,"$row\t.");	# because split(/\t/,"\t\t\t") does not return array of 4 empty fields 
	pop(@x);
	if ($#x != $#fieldNames) {
	    $x='<TABLE BORDER=1><TR><TD>field</TD><TD>10 chars of value</TD></TR>';
	    $i=0;
	    while (1) {
	    	local ($n,$v);
	    	$n = $fieldNames[$i];
	    	$v = substr($x[$i],0,20);
	    	$x .= "<TR><TR><TD>$n\n</TD><TD>$v\n</TD></TR>\n";
	    	last if $n eq '' && $v eq '';
	    	$i++;
	    }
	    $x .= '</TABLE>';
	    do wbFail ("TBL file inconsistent","$#x data items for $#fieldNames fields!\n<HR> $x");
	}

	$i=0;
	foreach $field (@fieldNames) {
	    $x[$i] =~ s/\033/\t/g;
	    $x[$i] =~ s/\034/\012/g;
	    $rec{$field} = $x[$i];
	    $i++;
	}	    
}

sub wbTestDir {

	unless (-d $_[0]) { mkdir ($_[0],$DIRMODE); }
	unless (-d $_[0]) { do wbFail("Cannot make/access directory $_[0]"); }
}

# test passwords

sub wbTestPass {

	local ($new,$old)=@_;

	local ($x);

	$x = &wbCryptPasswd ($new);

	$Log .= "newpass=$x\noldpass=$old\n";

	if ($old eq '' && $new eq '' || $x eq $old) {
	    return 1;
	} else {
	    if ($Group eq 'admin') {
		$ADMINPASS=1;
	        return 1;
	    } else {
	        return 0;
	    }
	}
}

# checks the values in the %rec array

sub wbTestRec {

	local ($err);

	$err = "";

	foreach $field (keys(%WBF)) {
	    next if $field =~ m/$;/;
	    $x = $WBF{$field};
            $_=$value=$rec{$field};

	    next if $WBF{$field,type} eq "BREAK";

	    if ( $_ && $WBF{$field,type} eq "FILE" && ! -f "$WBB{dataDir}/$value") {
		$err .= "WARNING: file $WBB{dataDir}/$value does not exist\n" ; #UK
		$err{$field}=1;
	    }

	    if ($x eq '1;' && $WBF{$field,type} eq 'EMAIL' && $value && (! ($value =~ /.+\@.+\..+/))) { 
 		$err .= "WARNING: bad email address at $field\n" ; #UK
		$err{$field}=1;
	    }

	    $y=1;
	    $* = 1;		# multiline matching
	    $y = eval $x;	# calculate
	    $* = 0;		# single line matching
	    $/=$break;		# perl5 workaround
	    if ($y) { 
	    } else {
		$m = $WBF{$field,cond};
		$m = $WBF{$field} if ! $m;
		$err .= "WARNING: bad value for <B>$field</B>:\n\t'$value' does not satisfy '<B>$m</B>'\n" ; #UK
		$err{$field}=1;
	    }
        }

	if (defined (&myRecVerify)) {
	    $err .= &myRecVerify();
	}

	return $err;
}

#
# return a good name for a temp file in current dir with ext. $_[0]
#

sub wbTmpFile {

	local ($dir,$ext) = @_;
	local ($x);

	$dir = "$dir/" if $dir ne "";   # not current dir

	$x = &wbRandKey();
	
        while (-e "$dir$x.$ext") {
	    $x = &wbRandKey();
	}

	return "$dir$x.$ext";
}

sub wbRandKey {

        local ($n) = @_[0];
        local (@a) = (0..9,'a'..'f');
        local ($x, $n, $c, $o, $base, @c, $i);
        $base = $#a+1;

        $n = $n || 4;
        $x = $base**$n;
        $x = int(rand($x));

        for ($i=1;$i<=$n;$i++) {
            $o = $x % $base;
            $c[$i]=$a[$o];
            $x = int($x/$base);
        }

        return (join('',@c));
}

sub wbRingField {

	local ($urlFld, $field);

	do wbSortFields();
	$urlFld = $WBB{ringField};
	if ($urlFld eq '') {
	    foreach $field (@Fields) {
		if ($WBF{$field,'type'} eq 'URL') {
		    $urlFld = $field;
		    last;
		}
	    }
	}

	return $urlFld;
}


sub cgiBrowseRing {

	# sort
	# id ... or random
	# op=next,prev,last,first,this,nextu,index,home,close
	# fr=top|bot

	$urlFld = &wbRingField();

	if ($urlFld eq '') {
	    do wbError ("Database does not contain URL's"); #UK
	    return;
	}

	# --- get URL ---

	$id = $CGI{id};
	$to = $CGI{to};
	$sort = $CGI{'sort'} || 'DEFAULT';
	$fr = $CGI{fr};

	if ($id ne '' && $to eq 'this') {
	    do wbParseFile("$WBB{dataDir}/$id.rec",1);
	    $url = $rec{$urlFld};
	    $newid=$id;

	} else {
	    do wbReadRecords($sort);

	    if ($to eq 'first') {
	        $i=0;
	    } elsif ($to eq 'last') {
	        $i=$#records;
	    } elsif ($to eq '') {
		$i = int(rand($#records));
	    } else {
	        $i=0;
	    	foreach $x (@records) {
	            ($did,$rest)=split(/\t/,$x);
	            last if $did eq $id;
	            $i++;
	    	}

		$i++ if $to eq 'next' || $to eq 'nextu';
		$i-- if $to eq 'previous';

		if ($i < 0) {
		    $i = $#records;
		}

		if ($i>$#records) {
		    $i=0;
		} 
	    }

	    $anchor = -3;

	    while (1) {

	        ($newid,$rest)=split(/\t/,$records[$i]);
	        do wbParseFile("$WBB{dataDir}/$newid.rec",1);
	        $url = $rec{$urlFld};

	        if ($url eq '' && $to eq 'nextu' && $i != $anchor) {
	 	    $anchor = $i;
		    $i++;
		    $i=0 if $i >$#records;
		} else {
		    last;
		}
	    }
	}

	if ($url eq '') {
	    $url = "$SCRIPT/Show?_id=$newid";
	}

	$noframes = "Your browser does not support frames. Sorry.";  #UK

	$eid = &htEscape($newid);
	$eurl = &htEscape($url);

	if ($CGI{fr} ne 'bottom') {
	    print <<EOM; 
Content-type: text/html

<HEAD>
<TITLE>$WBB{dbTitle} - RING</TITLE>
</HEAD>
<FRAMESET ROWS="28,*" FRAMEBORDER=0 FRAMESPACING=0 BORDER=0>
    <FRAME NAME="woda_toolbar" SRC="$SCRIPT/BrowseRingToolbar?id=$eid&sort=$sort&url=$eurl&fr=top"  SCROLLING=NO MARGINHEIGHT=1>
    <FRAME NAME="woda_page" SRC="$url" >
</FRAMESET>	    
<NOFRAMES><H1>$noframes</H1></NOFRAMES>
EOM
	} else {
	    print <<EOM;
Content-type: text/html

<HEAD>
<TITLE>$WBB{dbTitle} - RING</TITLE>
</HEAD>
<FRAMESET ROWS="*,28" FRAMEBORDER=0 FRAMESPACING=0 BORDER=0>
    <FRAME NAME="woda_page" SRC="$url" >
    <FRAME NAME="woda_toolbar" SRC="$SCRIPT/BrowseRingToolbar?id=$eid&sort=$sort&url=$eurl&fr=bottom"  SCROLLING=NO MARGINHEIGHT=1>
</FRAMESET>	    
<NOFRAMES><H1>$noframes</H1></NOFRAMES>
EOM
	}

	do wodaExit();
}

sub cgiBrowseRingToolbar {

	$sort=$GI{sort};
	$id=$CGI{id};
	$url=$CGI{url};
	$fr=$CGI{fr};

	$eid = &htEscape($CGI{id});
	$eurl = &htEscape($CGI{id});

	$ring = "Ring of Web pages";	#UK

    if ($WBB{homePage}) {
	if ($WBB{homePage} =~ m|/|) {
	    $homeURL = $WBB{homePage};
	} else {
	    $homeURL = "$WBB{homeURL}/$WBB{homePage}";
	}
    } else {
        $homeURL = $SCRIPT;
    }


$texts=<<EOM;
First page
Previous page
Show database record
Next page
Next page with an URL
Last page
List of all
Home page
WODA Home Page
Navigation bar at page top
Navigation bar at page bottom
Close navigation bar
EOM

@texts = split (/\n/,$texts);

#gif	target-url
@links = (
'first',	"$SCRIPT/BrowseRing?fr=$fr&sort=$sort&to=first&id=$eid",
'back',		"$SCRIPT/BrowseRing?fr=$fr&sort=$sort&to=previous&id=$eid",
'open4',	"$SCRIPT/Show?_id=$eid",
'forward',	"$SCRIPT/BrowseRing?fr=$fr&sort=$sort&to=next&id=$eid",
'fforward',	"$SCRIPT/BrowseRing?fr=$fr&sort=$sort&to=nextu&id=$eid",
'last',		"$SCRIPT/BrowseRing?fr=$fr&sort=$sort&to=last&id=$eid",
'','',
'browse',	"$SCRIPT/Search",
'home',		"$homeURL",
'powrwoda',	"$WBHome",
'topframe',	"$SCRIPT/BrowseRing?fr=top&sort=$sort&to=this&id=$eid",
'botframe',	"$SCRIPT/BrowseRing?fr=bottom&sort=$sort&to=this&id=$eid",
'close',	"$CGI{url}"
);
	
	print <<EOM;
Content-type: text/html

<HEAD><TITLE>Navigation Frame</TITLE></HEAD>
<BODY
	BGCOLOR=#000000
	TEXT=#FFFFFF
	TOPMARGIN=0
>
<TABLE
	BORDER=0
	WIDTH="100%"
	CELLPADDING="0" 
	CELLSPACING="0"
>
<TR VALIGN=TOP>
<TD ALIGN=LEFT>
EOM

	$j=0;
	for ($i=0;$i<$#links;$i+=2) {
	    $gif = @links[$i];
	    $url = @links[$i+1];
	    if ($gif eq '') {
		print "\n";
		next;
	    }
	    $text = @texts[$j++];
	    if ($gif eq 'open4' && $CGI{url} =~ /$SCRIPT/) {
		$gif = 'open1';
		$url = '';
		$a = 'AX';
	    } else {
		$a = 'A';
	    }
	    next if ($gif eq 'topframe' && $fr eq 'top');
	    next if ($gif eq 'botframe' && $fr eq 'bottom');

	    if ($j == 9) {
		print <<EOM;
<TD ALIGN=CENTER>
$WBB{dbTitle} - $ring
</TD>
<TD ALIGN=RIGHT>
EOM
	    }
	    $iconpar = $ICONPAR;
	    $iconpar = 'WIDTH=58 HEIGHT=21' if $gif eq 'powrwoda';

    	    print 
"<$a
HREF=\"$url\"
TARGET=_parent
><IMG
BORDER=0
ALIGN=TOP
SRC=$ICONURL/$gif.gif
$iconpar
ALT=\"$text\"
></$a>";
	}

print <<EOM;
</TD></TR></TABLE>
</BODY>
EOM
do wodaExit();


}

sub cgiBrowseAZ {

	$name = $CGI{name};

	@indexes = split (/\n/,$WBB{AZindex});
	@indexes = grep (/^$name\s/,@indexes);
	($dbname,$fields,$title) = split (/\s+/,$indexes[0],3);

	if ($dbname ne $name) {
	    do wbFail ("Index $name is not defined"); #UK
	}

	$x = "A-Z Index: ";	#UK
	$x .= $title;
	do printHead ($x);

	$x = "Index of words in field(s)";	#UK
	$x .= " <B>$fields</B>.";

	print "<P>$x\n";

	($lcFrom,$lcTo) = split(/ /,$WBB{intlLower});
	undef $lcEval;
	$lcEval = "tr/$lcFrom/$lcTo/" if $lcFrom;

	$wordFname = "_cache/words-$name.txt";
	if (&wbExpired($wordFname)) {

	    do wbSortFields();

	    # - restrict to some fields
	    @fields = split (/,/,$fields);
	    $lines = 1;	# index will be built of lines, not words
	    foreach $_ (@fields) {
		$seen{$_} = 1;
		if ($WBF{$_,type} !~ m/OPTION/) {
		    $lines=0;
		}
	    }

	    foreach $x (@PFields) {
		$Hidden{$x} = 1 unless $seen{$x};
	    }

	    do wbSearch	('','','','TAB','','');

	    foreach $_ (@list) {
		tr/\n/ /;
		tr/()<>,;|"${}!@#$%^&*()_+='\.\// /s;
		tr/[A-Z]/[a-z]/;
		s/\d/ /g;
		s/\s+/ /g;
		if ($lines) {
		    @words = split (/\n/,$_);
	        } else {
		    @words = split (/ /,$_);
		}
		foreach $word (@words) {
		    $words{$word}++;
		}
	    }

	    # do not index by some words like a, the, who, when
	    undef @words;
	    undef %sort;
	    ($coFrom,$coTo) = &wbCollate();
	    $coEval = "tr/$coFrom/$coTo/" if $coFrom;

	    @stopWords = split (/\s+/,$WBB{AZnot});
	    foreach $word (keys(%words)) {
		next if length($word) == 1;
		foreach $stop (@stopWords) {
		    if ($word =~ m/^$stop$/i) {
			$words{$word}=0;
			last;
		    }
		}
		$_ = $word;
		eval $coEval if $coEval;
		$sort{$word}=$_;
		# print "<BR>$word $sort{$word}\n";
	    }

	    # sort the words and print out
	    @w = keys(%sort);
	    @words = sort { $sort{$a} cmp $sort{$b} } @w;

	    open (h,">$wordFname") || do wbFail ("Cannot write to file $wordFname");
	    foreach $word (@words) {
		print h "$word\t$words{$word}\n";
	    }
	    close (h);

	}

	open (h,$wordFname);
	@lines = <h>;
	close (h);

	if ($CGI{how} eq 'frequent') {
	    do printAZfrequent($CGI{n});
	} else {
	    do printAZaz();
	}
}

sub printAZaz {

	$dletter='';
	foreach $_ (@lines) {
	    chop;
	    ($word,$count) = split (/\t/);
	    $_ = substr ($word,0,1);
	    unless (m/[a-z]/) {
	        eval $lcEval if $lcEval;	# do case lowering & other equivalences
	        tr/[A-Z]/[a-z]/;		# lower case
	    }
	    $sword = &htEscape($word);
	    $entry{$_} .= <<EOM;
<A HREF="$SCRIPT/Search?search=$sword">$word</A> <I>($count)</I><BR>
EOM
	    if ($_ ne $dletter) {
		push (@letters,$_);
		$dletter = $_;
	    }
	}

	# --- print contents

	print "<H2><A NAME=\"az\">\n</A>\n";

	foreach $_ (@letters) {
	    print "<A HREF=#$_>$_</A>\n";
	}

	print "</H2>\n\n";

	$t = "Browse most frequent."; #UK
	print <<EOM; #UK
<P><A HREF=$SCRIPT/BrowseAZ?name=$CGI{name}&how=frequent>$t</A>
<HR>
EOM

	foreach $_ (@letters) {
	     @items = split (/\n/,$entry{$_});
	     $x = &formatColumns(5,@items);
	     print <<EOM;

<H2>
<A HREF=#az><IMG SRC="$ICONURL/up.gif" $ICONPAR ALIGN=BOTTOM ALT=up></A>
<A NAME="$_">$_</A>
</H2>
$x
EOM

	}
}

sub printAZfrequent {

	$maxWords = $CGI{n} || 50;

	foreach $_ (@lines) {
	    chop;
	    ($word,$count) = split (/\t/);
	    $_ = $word;
	    eval $lcEval if $lcEval;	# do case lowering & other equivalences
	    tr/[A-Z]/[a-z]/;		# lower case
	    $count{$_}+=$count;
	}

	@words = keys(%count);
	@sortedWords = sort { ((999999-$count{$a}).$a) cmp ((999999-$count{$b}).$b) } @words;

	if ($#sortedWords+1 < $maxWords) {
	    $maxWords = $#sortedWords+1;
	}

	print "<H2>Most frequent $maxWords words</H2><OL>"; #UK

	undef @items;
	for ($i=0;$i<$maxWords;$i++) {
	    $word = $sortedWords[$i];
	    $sword = &htEscape($word);
	    $count = $count{$word};
	    print <<EOM;
<LI><A HREF="$SCRIPT/Search?search=$sword">$word</A> <I>($count)</I>
EOM
	}

	print "\n</OL>\n";
}

# read counted number of categories

sub readCatCount {

	local ($field) = @_;
	local ($file) = "_cache/count-$field.txt";
	local (@rows);
	if (&wbExpired($file)) {
	    $counts = &countCat($field,1);
	    open (H,">$file") || do wbFail("Cannot open $file for writing\n");
	    binmode(H);
	    print H $counts;
	    close(H);
	}

	open (H,$file);
	@rows= <H>;
	close(H);
	foreach $row (@rows) {
	    chop($row);	# newline
	    ($cat,$count)=split(/\t/,$row);
	    $catCount{$cat}=$count;
	}
}

# browse by fields in a tree

sub cgiBrowseTree {

	$field = $CGI{field};
	$separator = $CGI{separator} || ':';
	$value = $CGI{value};

	do readCatCount($field);

        $head = &formatFieldName($field);

	# --- the stuff above

	@subs = split(/$separator/,$value);
	if ($#subs == -1 && $value) {
	   @subs = ($value);
	}

	$recurse=$CGI{recurse} || 0;
	$base = "$SCRIPT/BrowseTree?field=$field&separator=$separator&recurse=$recurse";

	$b = "Browse by "; #UK
	$tit = "$b <A HREF=$base>$head</A> :";
	foreach $sub (@subs) {
	    if (! ($value =~ m/:$sub$/)) {			# ce ni zadnji
#staro		$esub = &htEscape($sub);
		$asub .= ":$sub";				# dodano	
                $asub =~ s|^:||o;				# pred ta prvim ni :
		$esub = &htEscape($asub);			# dodano
		$text = "<A HREF=$base&value=$esub>$sub</A>";
	    } else {
		$text = $sub;
	    }
	    $tit .= " $text :";
	    $super .= "<B>$text</B><BR>\n";
	}

	chop ($tit); # trailing :

	do printHead ($tit);

	# --- subcategories

	$x = 'Subcategories'; #UK
	$y1 = '(more)';	#UK
	$y2 = '(less)'; #UK
	$y = $y1;
	$y = $y2 if $recurse;
	$e = &htEscape($value);
	$alt = "$base&value=$e";
	if ($recurse == 1) {
	    $alt =~ s/recurse=1/recurse=0/;
	} else {
	    $alt =~ s/recurse=0/recurse=1/;
	}

	print "<H3>$x <A HREF=$alt>$y</A>:</H3>\n";

        @kwords = &wbParseOptions($field);
	@kwords = sort(@kwords);

	do printTree($value);

	# --- now make a less demanding search

	$s2 = "\"$value\"";
	$x = $value;
	$x =~ s/$separator/ /g;
	$x =~ s/\s+/ /g;
	$s2 = &htEscape("$s2 $x");


	if ($value ne '') {

	    $x = "Found items in $value"; #UK
	    print "<H3>$x <A HREF=\"$SCRIPT/Search?search=$s2\">(more)</A>:</H3>\n";

	    # exit through search

	    $CGI{search} = "/$field:\"$value\"";
	    do cgiSearch('H');

	    print "<UL>-</UL>" unless $dataHits;

	}
}

# prints Tree

sub printTree {

	local ($value)=$_[0];
	local (%seen,$yes,$subc,@kw,$sep);

	if ($value ne '') {		# in perl4 // does not match anything
	    @kw = grep(/$value/,@kwords);
	} else {
	    @kw = @kwords;
	}

	$sep = '';
	$sep = $separator unless $value eq '';

	print "<OL>";

	foreach $subc (@kw) {
	    if ($subc =~ m/^$value$sep([^$separator]+)/) {
		$sub = $1;
		if ($seen{$sub}) {
		    next;
		} else {
		    $c1=$c2=0;
		    $c1=$catCount{$subc} || 0;
		    undef @x;
		    @x = grep(/^$value$sep$sub/,keys(%catCount));
		    $c3 = $#x;
		    $c3 = 0 if $c3==-1;
		    foreach $x (@x) {
		    	$c2 += $catCount{$x};
			# print "<BR>/$value$sub$sub/$x/";
		    }
		    $c2=$c2-$c1;
		    $evlue = &htEscape("$value$sep$sub");
		    print "<LI><A HREF=$base&value=$evlue><B>$sub ($c1)</B></A>\n";
		    print "(and $c2 in $c3 subcategories)\n" if $c2; #UK
		    $seen{$sub}=1;
		    $yes=1;
		}
	        do printTree("$value$sep$sub") if $CGI{recurse};
	    }
	}

	# print "-" unless $yes;
	print "</OL>\n";
}

# wbTree (expresion,delim)
# creates a tree like structure out of database fields

sub wbTree {

    local ($expr,$delim) = @_;
    local ($selected);

    # do we have it in cache ?

    $fname = &wbFixId("$expr$delim");
    $fname = "_cache/$fname.3.cache";

    if (&wbExpired($fname)) {	

	do wbList ($expr,$expr);

	foreach $item (values(%print)) {
	    # print "$item $delim<BR>\n";
	    @items = split (/$delim/,$item);
	    @x_keys = split(/\n/,$items[0]);	# multivalue separated by \n
	    @x_vals = split(/\n/,$items[1]);	# make all combinations
	    foreach $xk (@x_keys) {
		foreach $xv (@x_vals) {
		    $items[0]=$xk;
		    $items[1]=$xv;
	            $key = $items[0].'|'.$items[1];
	            $treeCount{$key}++;
	            $treeMain{$items[0]}++;
	            $treeID{$key} .= "$item|";
		}
	    }
	}

	@cats = sort(keys(%treeMain));
	@subs = sort(keys(%treeCount));
	$cc=0;
	$sc=0;
	$out = '';

	open (h, ">$fname");
	$selected = select(h);

	print "\n<TABLE>\n";
	foreach $cat (@cats) {
	    next if $cat eq "";
	    print "<TR>\n" if ($cc%2 == 0);
	    print "<TD>\n";
	    $x = &htEscape("+\"$cat\"");
	    do printMenuTitle ($cat,"$SCRIPT/Search?search=$x");
	    @x =();
	    foreach $sub (@subs) {
		next unless $sub =~ m/^$cat\|(.*)/;
		$s = $1;
	        $x = &htEscape("+\"$cat\" +\"$s\"");
		push (@x,$s,"$SCRIPT/Search?&search=$x");
	    }
	    do printMenuItems(@x);
	    print "</TD>\n";
	    print "</TR>\n" if ($cc%2 == 1);
	    $cc++;
	}
	print "</TABLE>\n";

	select($selected);
	close h;

    }

    open (h,$fname);
    @x = <h>;
    close(h);

    return join('',@x);
}	

# trims @list from $first to $last

sub wbTrimList {
	local ($first,$last)=@_;

	$last = $#list if $#list < $last;
	@list = @list[$first..$last];
}

# updates the $sort.tbl file if needed
# or if $force 
sub wbUpdateTbl {
	local ($sort,$force) = @_;
	local ($file);

	$file = "_cache/$sort.tbl";
	if ($force || &wbExpired($file)) {

	    open (cache,">$file.wrk") || do wbFail("Failed to open $file.wrk for writing");
	    local ($selected);
	    $selected = select(cache);
	    do wbExport($sort,'TAB');
	    close (cache);
	    select($selected);
	    unlink $file;
	    rename ("$file.wrk","$file") || do wbFail ("Failed rename to $file");
	}
}

sub wbUserFileSave {

	local ($field) = @_;
	local ($fileName,$ext);

	# find file's extention

	$ext = $EXT{$field};

	# print $field,%EXT;

	$fileName = &wbTmpFile("","tmp.$field.$ext");

	open (h,">$fileName") || do wbFail("Cannot open $fileName\n");
	binmode(h);
	print h $CGI{$field};
	close h;

	if (-e $fileName) {
	    return $fileName;
	} else {
	    return "";
	}
}

# escapes special regular expression characters in a string

sub regexpEsc {

	local ($_) = $_[0];
	s/(\W)/\\$1/g;
	return $_;
}


# ht ###################################################################

# escapes non alphanums into %hex

sub htEscape {
	local ($x) = @_;
	$x =~ s/(\W)/&htToHex(ord($1))/ge;
	return $x;
}

sub htDemandCookie {
	# demands that cookies @_ are written by the
	# next printHead routine

	$DemandedCookies .= join('',@_);
}	

sub htFormatCookie {

	local ($name,$value,$path,$time) = @_;

	if ($path ne '') {	
	    # $path = $path . '/' unless $path =~ m|/$|; # some explorers want cookies with a trailing slash ??
            $path="path=$path;";
	}

	if ($time eq '') {
	    $time='expires=Wed, 1-Jan-2020 23:59:59 GMT';
	} elsif ($time eq "RESET") {	# in the past
	    $time='expires=Sun, 30-Nov-1997 23:59:59 GMT';
	} elsif ($time eq "SESSION") {	# after session
	    $time='';
	}

	return '' if $name eq '';
	return '' if $value eq '';

	$value = &htEscape($value);
	return "Set-Cookie: $name=$value; $path $time\n";
}

sub htParseSimple { # was parse data
    local($raw_data) = $_[0];
    local(@items,$key,$value);

    # Split different "NAME" and their values.

    unless ( $raw_data =~ m/\=/ ) {
	$_ = $raw_data;
	$_ =~ tr/+/ /;
        $_ =~ s/%(..)/pack("C", hex($1))/eg;
	$CGI{_isindex} = $_;
	return;
    }

    @items = split('&', $raw_data);

    # For each list of "NAME=its_value".

    for (@items) {

        $_ =~ tr/+/ /;

	if (m/\=/) {
            ($key,$value) = split('=',$_,2);
	} else {
	    ($key,$value) = ('_isindex',$_);
	}

        # The %xx hex numbers are converted to alphanumeric.
        $key   =~ s/%(..)/pack("C", hex($1))/eg;
        $value =~ s/%(..)/pack("C", hex($1))/eg;
	if (defined $CGI{$key}) {
	    $CGI{$key} = $CGI{$key} . "\x0A" . $value;
	} else {
            $CGI{$key} = $value;
	}

    }

}

sub htGetData {
	local($buffer,$toread,$read);

    	if ($ENV{'REQUEST_METHOD'} eq "POST") {
      	    $toread = $ENV{'CONTENT_LENGTH'};
	    binmode(STDIN);
      	    $read = read(STDIN,$buffer,$toread,0);
      	    if ($read != $toread) {
	 	do wbFail("Read $read bytes from STDIN, should read $toread\n");
            } 
      	    return $buffer;

    	} elsif ($ENV{'REQUEST_METHOD'} eq "GET") {
      	    return $ENV{'QUERY_STRING'};

     	} else {
      	    return 0;

    	}
}

sub htParseMulti {
	local($boundary,@pairs,$position);
 	local($raw_data,$value,$name,$part,$type);

# do printHead("xxx");

	undef %CGI;
 	$raw_data = &htGetData();

	unless ( $ENV{CONTENT_TYPE} =~ m|multipart/form-data| ) {
 	    &htParseSimple($raw_data);
 	    return;
        }

	# --- MIME style 

#do printHead("boundary stuff");
#print length($raw_data),"---",$ENV{'CONTENT_LENGTH'},"---$nread";
#do printENV();
#print "<PRE>$raw_data</PRE>";
#$xxx = $raw_data;

	($boundary = $ENV{CONTENT_TYPE}) =~ s/^.*boundary=(.*)$/\1/;
	@pairs = split(/--$boundary/, $raw_data);
	@pairs = splice(@pairs,1,$#pairs);

#print "<PRE>$raw_data";
#print join('<BR>',@pairs);
#print "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";

 	foreach $part (@pairs) {
	    if ($part =~ m/\x0D\x0A$/) {
		$CRLF = "\x0D\x0A";
	    } else {
		$CRLF = "\x0A";
	    }
	    ($head,$content)=split(/$CRLF$CRLF/,$part,2);
	    chop $content;
	    chop $content if length($CRLF)==2;

	    $head =~ s/\r//g;
	    $head =~ s/\n/;/g;
	    (@headers)=split(/\s*;\s*/,$head);
	    undef %hdr;
            foreach $item (@headers) {
	    	next if $item eq '';
	    	($name,$value)=split(/=|:/,$item,2);
	    	$value=~ m/\s*"*([^"]*)/;
	    	$value=$1;
	    	$hdr{$name}=$value;
#print "<BR>hdr($name)=($value)\n";
	    }

#print "<BR>",%hdr;

	    # store into variables 

	    $name = $hdr{'name'};
#print "<BR>CGI($name)\n";
            if (defined $CGI{$name}) {
            	$CGI{$name} = $CGI{$name} . "\x0A" . $content;
            } else {
            	$CGI{$name} = $content;
            }

	    if ($hdr{filename}) {
	    	$hdr{filename} =~ m/([^\.]*)$/;
	    	$EXT{$name} = $1;
		$EXT{$name} =~ tr/[A-Z]/[a-z]/;
	    	$C_TYPE{$name} = $hdr{"Content-Type"};
	    }

#print "<BR>",length($content),"content=($ddcontent)";
	}
}

sub htQuote {
	local ($_)=@_[0];

        s/\&/\&amp;/g;
	s/\>/\&gt;/g;
	s/\</\&lt;/g;
	s/\"/\&quot;/g;

	return $_;
}

#
# convert cookies into Assoc array
#

sub htReadCookies {

	local ($n,$v,$x,@x);

	@x = split (/;/,$ENV{HTTP_COOKIE});
	foreach $x (@x) {
# do printHead ("$x");
	    ($n,$v)=split(/\=/,$x);
# do printHead("$n=$v"); to ga nekaj lomi na win32
	    $n =~ s/\s//g;
            $v =~ s/\+/ /g;
            $v =~ s/%([\da-f]{1,2})/pack(C,hex($1))/eig;
	    $COOKIE{$n}=$v;

	}
}

sub htToHex {
	local ($_)=@_;
	return '%'.(0..9,'a'..'f')[$_/16].(0..9,'a'..'f')[$_ & 15];
}


sub htUnescape {

	$_[0] =~ s/\+/ /g;
        $_[0] =~ s/%([\da-f]{1,2})/pack(C,hex($1))/eig;
	return $_[0];
}

# prints settings of the database
# WBBs matching bpatt
# WBFs matching fpatt
# legends in legends set to 1

sub printStructure {

	local ($bpatt,$fpatt,$legends)=@_;

 	do admMeta();

	print "<H2>1. Database information</H2>\n" ; #UK

	print "<TABLE BORDER=0 WIDTH=100%>";

	$j=0;
	foreach $wbase (@MetaB) {
	    
	    if ($MetaB{$wbase,what} eq 'H') {
	        next unless $wbase =~ m/$bpatt/;
		print <<EOM;
<TR>
<TD ALIGN=CENTER COLSPAN=2 CLASS=MENUT>
<B>$wbase</B>
</TD>
</TR>
EOM
	    } else {

	        next unless $wbase =~ m/$bpatt/;
	        next unless defined $WBB{$wbase};

	        $value = &htQuote($WBB{$wbase});
	        print <<EOM;
<TR CLASS=DATA$j VALIGN=TOP>
<TD ALIGN=RIGHT WIIDTH=\"40%\">
<A NAME="_b$wbase">
<B>$wbase</B>
</A>
</FONT></TD><TD VALIGN=TOP>
<PRE>$value</PRE>
</TD>
</TR>
EOM
	    }
	}

	print "</TABLE>\n";

	print "<H2>2. Fields in database </H2>\n" ; #UK

	do wbSortFields();

	$nf = 0;
	foreach $field (@Fields) {
 	    $nf++;
	    print <<EOM;
<H3><A NAME="$field">2.$nf $field</A></H3>
<TABLE BORDER=0 WIDTH=100%>
EOM
	    $j=0;
	    foreach $attr (@MetaF) {
		next unless $attr =~ m/$fpatt/;
		next unless defined $WBF{$field,$attr} || $attr eq "";

		$x = $WBF{$field,$attr};
		$x = $WBF{$field} if $attr eq '';

		$x = &htQuote($x);

		$a = $attr;
		$a = "<I>valid-if</I>" if $attr eq "";

		if ($a eq 'options') {
		    @x = &wbParseOptions($field);
		    $x = join (',<BR>',@x);
		}

		# $j = !$j;
	        print "<TR CLASS=DATA$j><TD ALIGN=RIGHT VALIGN=TOP WIDTH=\"20%\">\n<B>$a</B>\n</TD>\n<TD VALIGN=TOP WIDTH=\"80%\">$x</TD></TR>\n";
	
	    }

	    print "</TABLE>\n";
	 
	}

	do admConfAttrs if $legends;
}

# agent ################################################################

sub cgiAgentAdd {

	unless ($CGI{email}) {
	    do wbError ("Email address not supplied") ; #UK
	    return;
	}

	$cookie = &htFormatCookie('email',$CGI{email});

	do printHead("Adding a job for Angie",$cookie) ; #UK
# print $cookie;
	do wbTestDir('_agent');
	chdir ("_agent") || do wbFail("cannot chdir to _agent dir");

	do agentRead($CGI{email});
	$CGI{_password} = $CGI{_password} || $CGI{_password1};

	return unless &agentTestPass($CGI{_password},$CGI{_password1},$CGI{_password2});

	# which days

	$days = ''; 
	# $1 = ''; # this hangs perl5
	foreach $x (sort(keys(%CGI))) {
	    next unless $x =~ m/^day:(.*)/;
	    next if $1 eq '';
	    $days .= "$1,";
	}
	chop ($days);

	unless ($days ne '') {
	    print "<H3 CLASS=ERROR>Angie does not know when to do it</H3>" ; #UK
	    return;
	}

	# define job line (title,when,now,since,search,format,sort,group)

	$CGI{title} =~ s/\t/ /g;
	$rec{jobs} .= join("\t",
		$CGI{'title'},		# 0
		$days,			# 1
		time,			# 2
		$CGI{'since'},		# 3
		$CGI{'search'},		# 4
		$CGI{'format'},		# 5
		$CGI{'sort'},		# 6
		$Group			# 7
	);

	$rec{jobs} .=  "\n";
	$rec{email} = $CGI{email};

	do agentWrite();

	print <<EOM ; #UK
Angie has stored your request <B>$CGI{title}</B>.
<HR> 
<H3>All your requests are now:</H3>
Only use the form below if you would like to change anything!
EOM
	do agentRead($CGI{email});
	do agentReviewForm();
}

sub cgiAgentAddForm {

	do printHead ("Form to add a job for Angie") ; #UK

	$CGI{from}='';
	$CGI{since}=time;

	$sppar = &formatSearchPar();
	$shpar = &formatHiddenSearchPar();
	@daysVal = ('0','1','2','3','4','5','6','m1','m8','m16','m24','m28');
	@days=('Sun','Mon','Tue','Wed','Thu','Fri','Sat<BR>','1st','8th','16th','24th','28th in the month') ; #UK
	$i=0;
	$days = '';
	foreach $day (@days) {
	    $days .= "<INPUT NAME=\"day:$daysVal[$i]\" TYPE=CHECKBOX>$day \n";
	    $i++;
	}

	$email = $COOKIE{email};

	$expl = <<EOM ; #UK
<P>You can ask our Angie to perform a search like above every few days
and, if she finds anything new, lets you know by email. Just tell
here when to do such a search and who to mail it to.
EOM

	@p = (	"Days to search for you","Some descriptive title of this search","Your email address","(Existing) protection password (twice)","Submit") ; #UK
	@v = (	$days,
		"<INPUT NAME=title SIZE=40>",
		"<INPUT NAME=email SIZE=40 VALUE=\"$email\">",
		"<INPUT NAME=_password1 TYPE=PASSWORD> <INPUT NAME=_password2 TYPE=PASSWORD>",
		"<INPUT TYPE=SUBMIT VALUE=\"  OK  \">"
		);

	$x = &formatNameVal(@p,@v);
	
	print <<EOM;
<FORM ACTION="$SCRIPT/AgentAdd" METHOD=POST>
<P>$sppar
<P>$expl
<P>$x
$shpar
</FORM>
EOM
}

sub cgiAgentReviewChanged {

	do printHead ("Changed Angie's to-do list") ; #UK

	chdir ("_agent") || do wbFail("cannot chdir to _agent");
	do agentRead($CGI{email});

	return unless &agentTestPass($CGI{_password},$CGI{_password1},$CGI{_password2});

	@jobs = split(/\n/,$rec{jobs});
	undef $rec{jobs};

	$i=0;
	foreach $job (@jobs) {
	    $rec{jobs} .= "$job\n" if $CGI{"row$i"};
	    $i++;
	}

	$CGI{_password} = $CGI{_password1} if $CGI{_password1};

	do agentWrite();
	if ($rec{jobs} ne '') {
	    print "<H2>Todo list has changed to:</H2>" ; #UK
	    do agentRead("$CGI{email}");
	    do agentReviewForm();
	} else {
	    print "<H2>You have deleted all your requests for Angie</H2>\n"; #UK
	    do agentDelete($CGI{email});
	}
}

sub cgiAgentReviewForm {

	do printHead ("Reviewing Angie's todo list") ; #UK

	chdir ("_agent") || &wbFail("cannot chdir to _agent");
	do agentRead("$CGI{email}");

	return unless &agentTestPass($CGI{_password});

	do agentReviewForm();

}

sub cgiAgentReviewWhat {

	# do wbFail("Not fully implemented") unless &agentGroup();

	do printHead ("Whose data should Angie review") ; #UK

	$email = $COOKIE{email};

	@p = ('Email address','Password','Review') ; #UK
	@v = (	"<INPUT NAME=email SIZE=40 VALUE=\"$email\">",
		"<INPUT NAME=_password TYPE=PASSWORD>",
		"<INPUT VALUE=\" OK \" TYPE=SUBMIT>"
	     );

	$x = &formatNameVal(@p,@v);

	print <<EOM;
<FORM ACTION=$SCRIPT/AgentReviewForm METHOD=POST>
$x
</FORM>
EOM
}


sub agentMail {
	($message)=@_;

	$| = 1;

	do findSendmail();

        open (MAIL, "|$SENDMAIL -t 2>&1") || return "Can't open $SENDMAIL!\n";
        print MAIL $message;
        close (MAIL);

	return '';
}

sub findSendmail {

	return if -e $SENDMAIL;

	$SENDMAIL = '/usr/sbin/sendmail';
	return if -e $SENDMAIL;

	$SENDMAIL = '/usr/bin/sendmail';
	return if -e $SENDMAIL;

	do wbFail('$SENDMAIL not configured properly',"Cannot execute $SENDMAIL");
}


sub agentRead {
	local ($f) = $_[0];

	undef %rec;
	do wbParseFile("$f.rec",1) if -f "$f.rec";
}

sub agentDelete {
	local ($f) = $_[0];

	unlink ("$f.rec");
}

sub agentReviewForm {

	print "<FORM ACTION=\"$SCRIPT/AgentReviewChanged\" METHOD=POST>";
	print "<TABLE BORDER=1>\n";
	@reqs = split(/\n/,$rec{jobs});

	local (@p) = ('Keep','Title','Days','Set up','Since','Search','Format','Sort','Group') ; #UK

	$nc = $#p + 1;

	print "<TR><TH COLSPAN=$nc><H3><BR>$rec{email}</H3></TH></TR>\n";

	print "<TR>\n";
	foreach $x (@p) {
	    print "<TH>$x</TH>\n";
	}
	print "</TR>\n";

	$i=0;
	foreach $req (@reqs) {
	    local (@v) = split(/\t/,$req,8);
	    $v[2] = &formatDate($v[2]);
	    $v[3] = &formatDate($v[3]);

	    print "<TR><TD><INPUT TYPE=CHECKBOX NAME=\"row$i\" CHECKED></TD>\n";
	    foreach $x (@v) {
		print "<TD>$x</TD>\n";
	    }
	    print "</TR>\n";
	    $i++;
	}

	@p = ("Last change:","From host:","Change password to (twice):","Delete unchecked rows from list","You add to the list from search results page") ; #UK
	@v = (	&formatDate($rec{_at}),
		$rec{_from},
		"<INPUT NAME=_password1 TYPE=PASSWORD> <INPUT NAME=_password2 TYPE=PASSWORD>",
		"<INPUT TYPE=SUBMIT VALUE=\"  OK  \">",
		''
		);

	$x = &formatNameVal(@p,@v);
	print <<EOM;
</TABLE>
<INPUT NAME=_password TYPE=HIDDEN VALUE="$CGI{_password}">
<INPUT NAME=email TYPE=HIDDEN VALUE="$CGI{email}">
<P>
$x
EOM
}

sub agentTestPass {

	local ($pass,$pass1,$pass2) = @_;
	# typed password, new pass 1, new pass 2

	if ($pass1 ne $pass2) {
	    print "<H2>Typed passwords do not match</H2>" ; #UK
	    return 0;
	}

	if ($rec{email} eq "") {
	    return 1;
	}

	if ( ! &wbTestPass( $pass, $rec{_password} )) { 
	    print "<H2>Bad password</H2>" ; #UK
	    return 0;
	}

	return 1;
}

# is the user allowed to use the agent

sub agentGroup {
	return 1 if ! &wbDenied($Group,"Agent");
	return 0;
}

# writes $rec into the right file

sub agentWrite {
	local ($x,$f);

	$x = &formatBinRec();
	$f = "$rec{email}.rec";
	open (h,">$f") || do wbFail("Cannot write into $f");
	print h $x;
	close (h);
}

# admin ################################################################

sub cgiAdmAgentProcess {

	do printHead ("Processing requests");
	print "<PRE>";

	do wbTestDir('_agent');
	chdir ("_agent") || do wbFail("cannot chdir to _agent dir");
	
	@agentRecords = &wbDir ('.*\.rec$');
# print @agentRecords;
	@x = localtime(time);
	$dDay = $x[6];
	$dDate = 'm'.$x[3];

	foreach $_ (@agentRecords) {
	    m/(.*).rec$/;
	    $userMail = $1;
	    do agentRead($1);
	    %agentRec = %rec;
	    %agentCGI = %CGI;
	    $agentGroup = $Group;
	    @agentRequests = split(/\n/,$agentRec{jobs});
	    $dRequest=0;
# print &formatNameVal(keys(%rec),values(%rec));
	    foreach $request (@agentRequests) {
		@ap = split(/\t/,$request);
		print "Processing for <A HREF=\"$SCRIPT/AgentReviewForm?email=$userMail\">'$userMail'</A> $ap[0]";
		unless ($ap[1] =~ m/\b$dDay\b|\b$dDate\b/ ) {
		    print "... today no need\n";
		    next unless defined $CGI{force};
# print "... force $ap[1] $dDay $dDate";
		}

		undef %CGI;

		$CGI{'since'} 	= $ap[3];
		$CGI{'search'} 	= $ap[4];
		$CGI{'format'}	= $ap[5];
		$CGI{'sort'}	= $ap[6];
		$Group		= $ap[7];


		$xx = $$;
# $xx = rand(1000);
		$agentFile = "$TMPDIR/agent-process.$xx.htm";
		open (AGENTFILE,">$agentFile");
		local ($selected);
		$selected = select(AGENTFILE);
		    chdir $WBB{dataDir};
		    $HTMLFILE=1;
	            do wbDo ("cgiSearch");
		    print "\n</BODY></HTML>";
		    $HTMLFILE=0;
		    chdir '_agent';
		select($selected);
		close AGENTFILE;
		
		open (h,$agentFile);
		$html = join('',<h>);
	        $ascii = &formatHtm2Txt($html);
		close(h);
		unlink ($agentFile);

		$html = "Content-type:text/html\n\n" . $html;

		$Group = $agentGroup;
		%CGI = $agentCGI;

		print " $allHits hits ";
		if ($allHits > 0) {
		    $bo = rand(1000);
		    $bo = "==========$bo";
		    $subject = "$allHits new hits in $ap[0]";	#UK
		    $ascii = <<EOM;				#UK
Attached is an HTML file with $allHits new records
from $WBB{dbTitle} database.

Here's an ASCII transcript:

$ascii

Regards,

Angie
EOM
		    $message = <<EOM;
From: "Angie" <$WBB{managerEmail}>
To: $userMail
Subject: $subject
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="$bo"

This is a multi-part message in MIME format.

--$bo
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

$ascii
--$bo
$html
--$bo--
EOM
		    $error = &agentMail($message);

#		print $ascii;

		    if ($error) {
			print " $error";
		    } else {
			@ap[3]=time;
			$r = join("\t",@ap);
		    	$agentRequests[$dRequest]=$r;
			print " ... message sent";
		    }
		}

		print "\n";
		$dRequest++;
		# each user's request
	    }

	    $agentRec{jobs} = join("\n",@agentRequests);
	    %rec=%agentRec;
# aha! this should not be commented on real version!
	    do agentWrite();

	    # each agent user
	}

	print "</PRE>\n";
}

sub cgiAdmClean {
	do printHead ("Cleaning the database");

	@bak = <*.bak>;
	@tmp = <*.tmp.*>;
	@all = (@bak, @tmp);

	foreach $file (@all) {

	    @x = stat($file);
	    next if $x[9]>(time-24*3600);

	    print "Deleting $file";
	    unlink $file || print " failed!!!";
	    print "<BR>\n";
        }
}

sub cgiAdmStatus {

	do printHead ('Database and WODA Status');

	print "<H3>Can we execute another Perl program?</H3>";

	$!='';
	$perl = "$PERL -v";

	$out = `$perl`;

	if ($out eq '') {
	    print <<EOM;
<P CLASS=ERROR>
Looks like it will not be possible to run external Perl programs.
Relational features such as &QRY function will not work!
Maype just <BR>\$PERL=$PERL<BR>was not set up right!
This is the error reported: <B>$!</B>
</P>
EOM
	} else {
	    print <<EOM;
<P>
Command <B>$perl</B> produced:
<PRE>
$out
</PRE>
<P>
EOM
	}


	print <<EOM;
<H3>Directories related to this application</H3>
<P>Note that only <B>$TMPDIR</B> and <B>$WBB{dataDir}</B> must exist.
<P>
EOM

	@x = (
	    $TMPDIR,
	    $WBB{dataDir},
	    "$WBB{dataDir}/_cache",
	    "$WBB{dataDir}/_agent",
	    $TESTCGIDIR
	);

	$testFile = "_test.xxx";
	$textText = "This is some test text";
	$close = "</EM></TD></TR>\n";
	$et = "<EM CLASS=ERROR>";
	print "<TABLE BORDER=1>\n";

	foreach $x (@x) {
	    $x = $DISK . $x unless $x =~ m/^[A-Z]\:/;
	    print "<TR ALIGN=LEFT VALIGN=TOP><TH>$x</TH><TD><EM CLASS=ERROR>\n";

	    unless (-e "$x") {
	        print "Does not exist!\n";
		print $close; next;
            }

	    unless (chdir ($x)) {
		print "Cannot chdir to $x!\n";
	    }

	    unless ( open (h, ">$x/$testFile") ) {
		print "Cannot open file $testFile for writing. Check permissions!\n";
		print $close; next;
	    } else {
		print h $testText;
		close (h);
	    }

	    unless ( open (h, "$x/$testFile") ) {
		print "Cannot open file $testFile for reading!\n";
	    } else {
		$xx = <h>;
		if ($xx ne $testText) {
		    print "Read text not equal to written text!\n";
		}
		close (h);
	    }

	    if ($MV) {
		`$MV $testFile $testFile.zzz`;
		unless (-e "$testFile.zzz") {
		    print "Could not MV $testFile\n";
		} else {
		    `$MV $testFile.zzz $testFile`;
		}
	    }

	    unless ( unlink ("$x/$testFile") ) {
		print "Cannot delete file $testFile\n";
		print $close; next;
	    }

	    print "</EM>OK<EM>\n";
	    print $close;
	}
	print "</TABLE>\n";

	chdir ($WBB{dataDir});

	print "<H3>Data</H3>\n";

	@files = &wbDir('\.rec$');
	$numFiles = $#files+1;

	$now = time;
	foreach $file (@files) {
	    @x = stat($file);
	    $week[int((time-$x[9])/(7*24*3600))]++;
	}

	print "<TABLE BORDER=1><TR><TH>week</TH><TD># records</TD></TR>\n";
	for ($i=0; $i<=$#week; $i++) {
	    print "<TR><TH>$i</TH><TD>$week[$i]</TD></TR>\n";
	}
	print "<TR><TH>total</TH><TD>$numFiles</TD></TR></TABLE>\n";

	print "<H3>Subroutines defined in package '$CALLER_PACKAGE'</H3>\n";

	@subs = @MYSubs;
	foreach $sub (@MYSubs) {
	    print "$CALLER_PACKAGE'$sub()<BR>\n";
	}

	print "<H3>Records</H3>\n";
	foreach $file (@files) {
	    $r = '';
	    $r.=" not readable " unless -r $file;
	    $r.=" not writable " unless -w $file;
	    $r.=" not owned by web server " unless -o $file;
	    if ($r) {
		print "<EM CLASS=ERROR>$file: $r</EM>\n";
	    }
	}

	print "<H3>External programs</H3> Essential functions work without them! <TABLE>";

	@progs = ('$SENDMAIL','$AT','$GREP','$DUMPABLEPERL','$UNDUMP');
	foreach $prog (@progs) {
	    $xprog = eval ($prog);
	    print "<TR><TD>$prog</TD><TD>$xprog</TD><TD>\n";

	    if (!$xprog) {
	        print "<EM CLASS=WARN>not defined</EM>";
	    } elsif (-x $xprog) {
		print "executable";
		next;
	    } elsif (-e $xprog && !UNIX) {
		print "exists";
		next;
	    } else {
		print "<EM CLASS=WARN>does not exist</EM>";
	    }

	    
	}

	print "</TABLE>";

	print <<EOM;
<H3>Can we use FETCH to get a Webpage into application?</H3>
EOM

	$pg = 'http://itc.fgg.uni-lj.si/woda/apage.htm';
	$back = &FETCH($pg);

	print <<EOM;
<P>Tried &FETCH(<A HREF=$pg>$pg</A>). This is what I got back:
<TABLE BORDER=1><TR><TD>
$back
</TD></TR></TABLE>
EOM
}

sub cgiAdmCompile {

	do printHead ('Making Compiled Version');

	if (!$DUMPABLEPERL) {
	    print "DUMPABLEPERL not defined!\n";
	    return;
	}
	
	$source = $0;
	if ($source =~ m|\.pl([^/]*)$|) {
	    $exe = "$`$1";
	} else {
	    print "Source $0 does not contain '.pl' string!\n";
	    return;
	}

	if ($source eq $exe) {
	    print "Source and exe are identical!";
	    return;
	}

	print "Compiling <B>$0</B> into <B>$exe</B>\n<PRE>The results of compilation:\n";

	print `$DUMPABLEPERL $source -dump 2>&1` if $WBB{dataDir};	# compile application
	print `$DUMPABLEPERL -u $source 2>&1` unless $WBB{dataDir};	# compile wbxx.pl only
	print `$UNDUMP $DUMPABLEPERL core -o $exe 2>&1`;
	print `$CHMOD +x $exe 2>&1` if $CHMOD; 
	print "\n";
	print `ls -l $exe 2>&1`;

}

sub cgiAdmConfAttrs {

	do printHead ("Configurable Attributes of a WB database");

	do admMeta();
	do admConfAttrs();
}

sub cgiAdmCreate {


	if ($CGI{filename}) {
	    do printHead("Structure Modification");
	} else {
	    print "Content-type: text/plain\n\n" unless $HTMLFILE;
	}

	do admCreate();

	do wodaExit();
}

sub admCreate {

	do admMeta();

	$CGI{language} =~ tr/[A-Z]/[a-z]/;

	$lib = "$WBPath/$WBFile";
	$now = &formatDate(time);

	$top = <<EOM;
#!$PERL

require "$lib" unless defined &main;

# EDIT wb.pl to get correct pointers in the lines above
#
# 	WODA definition
#
# generated by $lib version $VERSION at $now
#
# INSTRUCTIONS:
#     save as *unix* file into cgi directory of your server
#     Save ... in MSDOS/Windows often creates pairs of CRLF as line terminators
#     unix needs CR only!
#
# w a r n i n g
#	may need manual editing (see top and end of file for string EDIT)
#	may need debugging

#
# Database definition:
#

EOM

	$end = <<EOM;

# add-in functions are here:
require "\$WBB{'requireFile'}" if \$WBB{'requireFile'};

# for the compiled version
dump START if \$ARGV[0] eq '-dump';
START:

# call the real thing

do main();

EOM


	# add to string $definition

	$definition = '';

	foreach $a (@MetaB) {
	   next if $MetaB{$a,what} eq 'H';
	   next if $CGI{$a} eq '';
	   $name = '$WBB{' . "'" . $a . "'" . '}';
	   $definition .= &admMetaOutput($name,$CGI{$a});
	}
		
	$definition .= <<EOM;

#
# Field definitions:
#

\$i=1000;		# counter

EOM

	$i=1;
	while ($CGI{"_f$i"}) {
	   $fName = $CGI{"_f$i"};
	   $i0 = $i*10;

	   $definition .= <<EOM;

\$x='$fName';	# ------------------------------ 
\$WBF{\$x,srt}=\$i--;
EOM
	   foreach $a (@MetaF) {
	   	next if $CGI{"$a$i"} eq '';
	   	$name = '$WBF{$x,' ."'" . $a . "'" . '}';
		$name = '$WBF{$x}' if $a eq '';
	   	$definition .= &admMetaOutput($name,$CGI{"$a$i"});
	   }
	   $i++;
	}

	if ($PERL) {

	    unlink "$TMPDIR/$$";
	    open (h,"|$PERL -c 1> $TMPDIR/$$ 2>&1");    # xxx fails on NT/95
	    print h $definition;
	    close h;

	    open (h,"$TMPDIR/$$");
	    @x = <h>;
	    close h;

	    unlink "$TMPDIR/$$";

	} else {

	    print "WARNING: Syntax of the definition could not be checked on this non-unix system\n";
	    $x[0]='syntax OK';

	}

	if (!($x[0] =~ m/syntax OK/) && $x[0] ne '') {
	    print "<H3 CLASS=ERROR>There are errors in your definition:</H3>\n<PRE>";
	    print @x;
	    print "\n";
	    @def = split (/\n/,$definition);
	    $i = 1;
	    foreach $x (@def) {
		$x = &htQuote($x);
		print "$i:\t $x\n";
		$i++;
	    }
	    print "</PRE>";

	} else {
	    if ($x[0] eq '') {
		print "<P CLASS=WARN>It was not possible to verify the definition. Use with care.</P>";
	    }
	    $filename = "$TESTCGIDIR/$CGI{filename}" if $CGI{filename};
	    if ($filename && open (h,">$filename")) {
	        print h $top;
	        print h $definition;
	        print h $end;
		close h;
		`$CHMOD +x $filename` if $CHMOD;
		if (-e $filename) {
		    print <<EOM;
New database definition was stored as $filename.<P>
<BR> To try it, click <A HREF="$TESTCGIURL/$CGI{filename}">here</A>!
EOM
		} else {
		    print <<EOM;
<P CLASS=ERROR>An error occured while trying to store the new definition!</P?
EOM
		}
	    } else {
	        print "<P CLASS=ERROR>Could not create file <U>$filename</U>. Are you sure $TESTCGIDIR exists and is
writable by httpd process?</P>\n";
		print "<PRE>";
		print &htQuote($top);
	        print &htQuote($definition);
	        print &htQuote($end);
		print "</PRE>";
	    }	
	}

}

sub cgiAdmCreateForm {

	# CGI{no} ... number of fields
	# CGI{quick} ... show the essential fields only

	do printHead ("Create new Web Oriented DAtabase");

	do admMeta();
	# do admPrintWBBs();

	if (defined $CGI{quick}) {
	    print "Only the mandatory parameters are listed. Use MODIFY STRUCTURE option to refine the database";
	} else {
	    print "Parameters marked with '*' are optional.<P>\n";
	}

	print "<FORM ACTION=$SCRIPT/AdmCreate METHOD=POST>";

	print "<H2>1. Database features</H2><TABLE CLASS=FORM WIDTH=\"100%\">\n";

	foreach $wbb (@MetaB) {
	    print &admMetaInput($wbb,'');
	}

	print "</TABLE><H2>2. Fields</H3>\n";

	do admPrintFieldForm(1,$CGI{'no'});
	$fn = 'new.pl';
	do admPrintFormEnd();
}

sub cgiAdmSetEnv {

	do printHead("Storing values of some ENV variables");
	do admSetEnv();
}

sub cgiAdmCronModify {

	do printHead("Modifying Crontab Entries");

	$cron = `$CRONTAB -l`;

	@cron = split (/\n/,$cron);
	@cron = grep (!m|$0|,@cron);
	$cron = join ("\n",@cron);

	if ($CGI{action} eq 'add') {
	    $cron .= &wbCronjob();
	}

	open (h,">$TMPDIR/$$.cro") || do wbFail("Cannot open crontab file");
	print h $cron;
	close (h);
	print "<P>Results from crontab:<PRE>\n";
	print `$CRONTAB $TMPDIR/$$.cro 2>&1`;
	print "</PRE>\n";
	# unlink ($TMPDIR/$$.cro);

	$crontab = `$CRONTAB -l`;
	print <<EOM;
<P>The new crontab file is:
<PRE>
$cron
</PRE>
EOM
}

sub cgiAdmAtNow {

	do printHead("Processing of Cron Job Now Using At");

	print &wbAtdo();
	if ($?) {
	    print <<EOM;
<HR>
<P>Looks like the at command failed.
EOM
	}
}

sub wbCronjob {	

	$a = &wbAtjob();
	return <<EOM;
#
# WODA job for $0
0 1 * * * $a
EOM
}

sub wbAtdo {
	local ($job);

	$job = &wbAtjob();

	open (at,">$TMPDIR/$$.at");
	print at $job;
	close (at);

	return `$AT -f$TMPDIR/$$.at now 2>&1`;
}

sub wbAtjob {

	do findSendmail();

	return "$0 -x AdmDaily 2>&1 | $SENDMAIL $WBB{managerEmail}";
}

sub cgiAdmCrons {

	do printHead("Required crontab entries");
	
	print <<EOM;
<P><B>WARNING:</B> If you called
this function form a test database, then results are not valid.
You should run it from the real database!
EOM

	$x = &admSetEnv();

	print <<EOM;
<P>Current environment was stored so that the system
will work out of the WWW/CGI environment.
<P>The saved environment is:
<PRE><B>$x</B></PRE>
<P>These tasks could be part of your crontab file:
EOM
	$prog = &wbCronjob();

	print "<PRE><B>$prog</B></PRE>";

	print <<EOM;
<P>On systems that unlike UNIX do not support cron,
you should execute the above command once a day or
have "system agent" run it from time to time.
EOM

	$crons = `$CRONTAB -l 2>&1`;
	$x = getpwuid($>);
	if ($crons =~ /allowed/) {
	    print <<EOM;
Cron jobs cannot be set automatically on this system.
You should ask the systm administrator to allow user
$x to run cron and at jobs by adding
<TT>$x</TT> to (usually)
<TT>/usr/lib/cron/cron.allow</TT> and to 
<TT>/usr/lib/cron/at.allow</TT>.
EOM
	} else {
	    print <<EOM;
<P> More options:
<UL>
<LI><A HREF="$SCRIPT/AdmCronModify?action=add">
Add this to the Cron table now.
</A>
<LI>
<A HREF="$SCRIPT/AdmCronModify?action=remove">
Remove this from the Cron table.
</A>
<LI>
<A HREF="$SCRIPT/AdmAtNow">
Run this now using command '$AT'.
</A>
</UL>
EOM
	}
}

sub cgiAdmDelPass {

	$id = $CGI{_id};
	do printHead("Deleting password for $id");

	open (h, "$id.rec") || &wbFail("Cannot open $id.rec for reading");
	@x = <h>;
	close(h);
	if($x[0] eq "\n") {
	    $y[0] = $x[0];
	    shift(@x);
	    %r=@x;
	    foreach $x (keys(%r)) {
	        next if $x eq "_password\n";
	        push (@y,$x,$r{$x});
	    }
	} else {
	    foreach $x (@x) {
		push (@y,$x) unless $x =~ m/^%_password/;
	    }
	}

	open (h,">$id.rec") || &wbFail("Cannot open $id.rec for writing");
	print h @y;
	close h;

	print "<H1>Done!\n</H1>";
}

sub cgiAdmDisplayStructure {

	do printHead ("Structure of database $WBB{dbTitle}");
	do printStructure('.','.',!$CGI{nolegends});
}

sub cgiAdmExpire {

	$CGI{days} = $CGI{days} || $WBB{deleteAfter} || 0;
	$CGI{days}*=1;
	if ($CGI{days} <= 0) {
	    do printHead ("Nothing expired");
	    return;
	}		

	do printHead ("DELETING records older than $CGI{days} days");

	$then = time - $CGI{days}*24*3600;

	@all = &wbDir('.*rec$');
	$allN = 0;
	$delN = 0;

	foreach $rec (@all) {

	    $allN++;

	    @x = stat ($rec);
	    next if $x[9] > $then;

	    $delN++;

	    $rec =~ m/(.*)\.rec$/;
	    $id = $1;

	    @del = &glob("$id.*");
	    $del = join (' ',@del);
	    print "<BR>Deleted: $del\n";
	    unlink @del;
	}

	print "<P>All files $allN. Deleted $delN.\n";
}


sub cgiAdmExpireForm {
	do printHead ("Delete old records from the database");
	$d = $WBB{deleteAfter};

	print <<EOM;

<FORM ACTION="$SCRIPT/AdmExpire" METHOD=GET>
<P>
Delete files older than <INPUT NAME="days" SIZE=5 VALUE="$d"> days.
<P>
<INPUT TYPE=SUBMIT  VALUE="DELETE!">
</FORM>
EOM
}


sub cgiAdmExportCSV {

	do wbExport('DEFAULT','CSV');
	do wodaExit();
}

sub cgiAdmExportCSVS {

	do wbExport('DEFAULT','CSVS');
	do wodaExit();
}

sub cgiAdmExportID {

	print "Content-type: text/plain\n\n" unless $HTMLFILE;

	do wbSearch('','','','"$rec{_id}"');

	print '$tempList = (';
	print "\n";

	foreach $x (@list) {
	    print "'".$x."'";
	    print ",\n";
	}

	print ');';
	print "\n";

	do wodaExit();
}

sub cgiAdmExtractCatForm {

	do printHead("Extract Categories");

	do wbSortFields();
	foreach $x (@PFields) {
	    $fieldPull .= "<OPTION>$x\n";
	}

	print <<EOM;
This routine extracts values from a field and prints them out
in a suitable way for a definition of an OPTION typed field.
<FORM ACTION="$SCRIPT/AdmExtractCat">
<SELECT NAME="field">
$fieldPull
</SELECT> Select a field.<BR>
<INPUT NAME=count TYPE=CHECKBOX> Check to display count list.<BR>
<INPUT TYPE=SUBMIT VALUE="EXTRACT">
</FORM>
EOM
}

# counts categories in $field and returns them in
# an ascii string ... category and count are TAB separated

sub countCat {

	local ($field,$count) = @_;
	local ($ret);

	$f = "\$rec{$field}";

	do wbSearch('','','',"\"$f\"");

	undef %cat;

	foreach $x (@list) {
	    @llist = split(/\n/,$x);
	    foreach $y (@llist) {
	        $cat{$y}++;
	    }
	}

	foreach $cat (sort(keys(%cat))) {
	    next if $cat eq '';
	    $ret .= "$cat\t$cat{$cat}\n" if $count;
	    $ret .= "$cat\n" unless $count;
	}

	return $ret;
}
	
sub cgiAdmExtractCat {

	print "Content-type: text/plain\n\n" unless $HTMLFILE;

	$field = $CGI{field};

	$opts = &countCat($field,$CGI{count});

	print <<'EOT';
$WBF{$x,type}='OPTION';
$WBF{$x,options} = <<EOM;
EOT
	
	print "$opts" . "EOM\n";
	do wodaExit();
}



sub cgiAdmExportTAB {

	do wbExport ('DEFAULT','TAB');
	do wodaExit();
}

sub admReadCSV {

	local ($how) = @_;

	# get rid of CRs

	$CGI{csv} =~ s/\r//g;
	@csv = split (/\n/,$CGI{csv});
	$line = 0;

	# print "<PRE>$#csv == $CGI{csv}</PRE>";

	while ($dLine = shift(@csv)) {

	    undef %rec;

	    $line++;	    

#	    print "<BR>Line $line</H3>\n";

	    # open " in a line ?

	    while ( ($dLine =~ tr/"/"/) % 2. ) {
	        
		if (@csv) {
		    $dLine .= "\n";		# removed by split
		    $dLine .= shift(@csv);	# next line
		} else {
		    print "<H3>Bad .csv file at line $line; \" did not close</H3>\n";
		    return;
		}
	    } 
    
 	    @flds = split (/$delim/,$dLine);

	    if ($line == 1) {
		if ($#flds < 1 && $delim eq ',') {
		    $delim = ';';
 	            @flds = split (/$delim/,$dLine);
		}
		if ($#flds < 1 && $delim eq ';') {
		    $delim = ',';
 	            @flds = split (/$delim/,$dLine);
	        }

	        print "Fields ($#flds) are:<BR>";
	        print join("<BR>\n",@flds);
	        print "<BR><HR>\n";
	    }

	    $field = 0;

	    while (1) {
		last unless (@flds);

		$f = shift (@flds);

		$field++;

		while (($f =~ tr/"/"/) % 2) {
		    if (@flds) {
		    	$f .= $delim . shift (@flds);
		    } else {
		        print "<H3>Bad .csv file at line $line; \" did not close</H3>\n";
		        return;
		    }
		}

		$f =~ s/^"//;
		$f =~ s/"$//;
		$f =~ s/""/"/g;

		if ($line == 1) {
		    $key[$field] = $f;
		} else {
		    $rec{$key[$field]} = $f;
		    do admGuessFieldType($field,$f) if $how eq 'CREATE';
		}

	    }

	    if ($line > 1) {
		$e = &wbTestRec();
	        if ($WBB{key}) {
		    $x = $WBB{key};
	    	    $newId = eval $x;
	    	    $newId = &wbFixId($newId);
		    $id[$line] = $newId;

            	    $to = "$WBB{dataDir}/$newId.rec";
		    if (!defined($CGI{overwrite})) {
		        if ( -e $to ) {
			    $e = $e . "\nRecord exists\n";
		        }
		    }
		} else {
		    $id[$line] = $rec{_id};
		}

		$err[$line] = $e;
	        $keepUnderscores=1 if $rec{_from} || $rec{_at} || $rec{_password};
		$rec[$line] = &wbRecPrint();
		$at[$line]=$rec{_at} if $rec{_at};
		print &wbRecHtml() unless $CGI{'quiet'};
	    } elsif ($how eq 'CREATE') {
		undef %WBF;

		for ($iii=1;$iii<=$#key;$iii++) {

		    $field = $key[$iii];

		    $CGI{"_f$iii"} = $field;
		    $CGI{"$iii"}='1;';
		    $CGI{"type$iii"}='INPUT';

		    $WBF{$field}='1;';
		    $WBF{$field,'type'}='INPUT';
		}
	    }
	}
	
	print "<H3>$line rows read</H3>";

}

sub admGuessFieldType {

	local ($field,$data) = @_;

	return if $CGI{"type$field"} =~ m/EMAIL|URL|HTMLAREA/;
	if ($data =~ m/\@/) {
	    $CGI{"type$field"} = 'EMAIL';
	    print "I guess column $field is an email!\n";
	} elsif ($data =~ m/^http:\/\/|^ftp:\/\/|^news:|^mailto:/) {
	    $CGI{"type$field"} = 'URL';
	    print "I guess column $field is an URL!\n";
	} elsif ($data =~ m/\034/ || length $data>100) {
	    $CGI{"type$field"} = 'HTMLAREA';
	    print "I guess column $field is an HTMLAREA!\n";
	}
}

sub cgiAdmImport {

	do printHead ("Import results");

	$delim=$CGI{fsep} || ';';

	if ($CGI{csv} eq '') {
	    print "<H3 CLASS=ERROR>No csv file supplied</H3>\n";
	    return;
	} else {
	    do admReadCSV();
	}

	# --- write to disk ?

	$x = join ("",@err);
	if ($x && ! defined($CGI{eignore})) {
	    print "<H3 CLASS=ERROR>ERRORS IN INPUT DATA:</H3>\n";

	    for ($i=2;$i<=$#err;$i++) {
		if ($err[$i]) {
		    print <<EOM;
<H3 CLASS=ERROR>Errors in line $i</H3>
<PRE>$err[$i]</PRE>
EOM
    		}
	    }
	    print "<H3>Nothing was saved!</H3>\n";


	} else {
	    print "<H2>No errors in input data</H2>\n";

	    for ($inLine=2;$inLine<=$#rec;$inLine++) {

		$home = $WBB{dataDir};

		if ($WBB{key} || $id[$inLine]) {
            	    $to = "$home/$id[$inLine].rec";
		} else {
	    	    $to = &wbTmpFile ($home,'rec');
		}		

		$to =~ m|/([^/]+)\.rec$|;
		$id = $1;

		if (-e $to && !defined($CGI{overwrite})) {
		    print "<BR>Line $i NOT SAVED (duplicate!)\n";
		    next;
		}

		open (h,">$to") || next;
		print h $rec[$inLine];
		close h;

		if ($at[$inLine]) {
		    utime $at[$inLine], $at[$inLine], $to;
		}

	        do wbDatabaseChanged();

		print "<BR>Line $inLine was saved to <A HREF=\"$SCRIPT/Show?_id=$id\">$id</A>\n";
	    }
	}
}

sub cgiAdmImportForm {

	do printHead ("Import .CSV file into database");
	print <<EOM;

<DIV ALIGN=LEFT>
<FORM ENCTYPE="multipart/form-data" ACTION="$SCRIPT/AdmImport" METHOD=POST>

<P>
<B>CSV file on your disk</B>, which contains a title line with field names and
.CSV records (as saved, for example, by MS Excel or MS Access):
<BR><INPUT TYPE=FILE SIZE=40 NAME="csv">
<P>
<BR><INPUT TYPE=CHECKBOX NAME="overwrite"> The imported data may overwrite the existing data.
<BR><INPUT TYPE=CHECKBOX NAME="eignore"> Ignore errors in the imported data.
<BR><INPUT TYPE=CHECKBOX NAME="quiet"> Don't display all records.
<BR><SELECT NAME="fsep"><OPTION VALUE=",">comma (,)<OPTION VALUE=";">semicolon (;)</SELECT> Field separator.
<P><B>Password</B> (optional) for <I>all</I> records.
<BR><INPUT TYPE=PASSWORD NAME=\"_password\" SIZE=10>
again
<INPUT TYPE=PASSWORD NAME=\"_password1\" SIZE=10>
<P>
<INPUT TYPE=SUBMIT  VALUE="IMPORT!">

</FORM></DIV>
EOM
}

sub cgiAdmCreateFromDataForm {

	do printHead ("Create WODA from CSV data");

	if ( -w $TESTCGIDIR ) {
	    print <<EOM;
You can crate a brand new database from data you have in
.CSV format - e.g. in MS Access or MS Excell. You must provide a few
key database features and supply a file name with the data.
EOM
	    print <<EOM;
Cannot use this function because TESTCGIDIR=$TESTCGIDIR
is not writeable. Check the value of TECTCGIDIR as setup
in the sub mainConfig and check the directory priviliges.
EOM
	}

	do admMeta();
	$CGI{quick}=1;	# only mandatory stuff

	print <<EOM;
<DIV ALIGN=LEFT>
<FORM ENCTYPE="multipart/form-data" ACTION="$SCRIPT/AdmCreateFromData" METHOD=POST>
<H2>Database features</H2><TABLE BORDER=1 WIDTH="100%">
<TABLE><TR>
EOM

	foreach $wbb (@MetaB) {
	    print &admMetaInput($wbb,'');
	}

	print <<EOM;
</TR>
</TABLE>
<TABLE>
<TR><TD COLSPAN=2>
<H2>Other</H2>
</TD></TR>

<TR>
<TD>CSV file on your disk, which contains a title line with field names and
.CSV records (as saved by MS Excell or MS Access):</TD>
<TD>$INPUTON<INPUT TYPE=FILE SIZE=40 NAME="csv">$INPUTOFF</TD>
</TR>

<TR>
<TD>Field separator:</TD>
<TD><SELECT NAME="fsep"><OPTION VALUE=",">comma (,)<OPTION VALUE=";">semicolon (;)</SELECT></TD>
</TR>

<TR>
<TD>Name of field which contains a unique record id (optional):</TD>
<TD><INPUT NAME="IDfield" SIZE=10 VALUE="_id"></TD>
</TR>

<TR>
<TD>File name for the cgi script to be generated in $TESTCGIDIR</TD>
<TD><INPUT NAME="filename" SIZE=10></TD>
</TR>

<TR>
<TD>Password (optional) for <I>all</I> records.</TD>
<TD><INPUT TYPE=PASSWORD NAME=\"_password\" SIZE=10>
again
<INPUT TYPE=PASSWORD NAME=\"_password1\" SIZE=10>
</TD>
</TR>
</TABLE>
<INPUT TYPE=SUBMIT  VALUE="CREATE FROM EXAMPLE!">

</FORM></DIV>
EOM
}


sub cgiAdmCreateFromData {

	do printHead ("Creating Database From Supplied Data");
	print "<DIV ALIGN=LEFT>\n";


	# --- make data directory

	if (-d $CGI{dataDir}) {
	    print "<B>Warning:</B> $CGI{dataDir} already exists; files will be added to it.\n";
	} else {
	    mkdir ($CGI{dataDir},0777);
	    if (-d $CGI{dataDir}) {
		print "<P>Created $CGI{dataDir}\n";
	    } else {
	        print "<H3>Error: Could not create directory $CGI{dataDir}</H3>\n";
	        return;
	    }
	}

	# --- set record key

	if ($CGI{IDfield}) {
	    $WBB{key} = "\$rec{'$CGI{IDfield}'}";
	}

	# --- parse CSV file

	print "<P>Parsing the .CSV file\n\n";

	$delim=$CGI{fsep} || ';';

	if ($CGI{csv} eq '') {
	    print "<H3>No csv file supplied</H3>\n";
	    return;
	} else {
	    $CGI{quiet}=1;
	    do admReadCSV('CREATE');
	}

	# --- write records

	for ($inLine=2;$inLine<=$#rec;$inLine++) {

	    $home = $CGI{dataDir};

	    if ($id[$inLine]) {
                $to = "$home/$id[$inLine].rec";
	    } else {
	        $to = &wbTmpFile ($home,'rec');
	    }

	    $to =~ m|/([^/]+)\.rec$|;
	    $id = $1;

	    open (h,">$to") || next;
	    print h $rec[$inLine];
	    close h;

	    print "<BR>Wrote row $inLine to $to\n";
	}

	# --- create description

	print "<H3>Writing database definition:</H3>\n";

	do admCreate();

	print "</DIV>\n";
}

sub cgiAdmMenu {

	do printHead ("Administration menu");

	if ($WBB{dataDir} && ! -s "$WBB{dataDir}/_cache/env") {
	    do admSetEnv();
	    print "Environment has been saved for off-line processing";
	}

	print "<TABLE><TR><TD WIDTH=50% VALIGN=TOP>";

	    do printMenuTitle ("Documentation");
	    do printMenuItems(
		"Administrator's manual","http://itc.fgg.uni-lj.si/woda/man.htm",
		"Configurable parameters","$SCRIPT/AdmConfAttrs",
		"Display global variables","$SCRIPT/AdmPrintVars",
		"CGI-API","$SCRIPT/AdmPrintCGIAPI",
		"Perl-API","$SCRIPT/AdmPrintPerlAPI"
		);

	    do printMenuTitle ("Status");
	    do printMenuItems(
		"Show debug info","$SCRIPT/Debug",
		"Database status","$SCRIPT/AdmStatus"
		);

	    do printMenuTitle ("Database structure");
	    do printMenuItems(
		"Display structure","$SCRIPT/AdmDisplayStructure",
		"Display structure without legends","$SCRIPT/AdmDisplayStructure?nolegend=1",
		"Modify structure","$SCRIPT/AdmModifyStructureFrames",
		"Modify structure without frames","$SCRIPT/AdmModifyStructure"
	    	);

	    do printMenuTitle ("Create database");
	    do printMenuItems(
		"Quick create new with ...","",
		"10 fields","$SCRIPT/AdmCreateForm?no=10&quick=1",
		"20 fields","$SCRIPT/AdmCreateForm?no=20&quick=1",
	        "50 fields","$SCRIPT/AdmCreateForm?no=50&quick=1",
		"","",
		"Create new from CSV data","$SCRIPT/AdmCreateFromDataForm"
		);

	print "</TD><TD WIDTH=50% VALIGN=TOP>";

	    do printMenuTitle ("Periodic tasks");
	    do printMenuItems(
		"Delete expired records","$SCRIPT/AdmExpireForm",
	   	"Clean(!) .bak and .tmp files","$SCRIPT/AdmClean",
		"Make compiled script","$SCRIPT/AdmCompile",
		"then Make static pages and cache","$SCRIPT/AdmStatic",
		"View what should be part of crontab file and save environment","$SCRIPT/AdmCrons",
		"Clean, expire and update static ... all in one go","$SCRIPT/AdmDaily",
		"Process Agent Requests","$SCRIPT/AdmAgentProcess"
		);

	    do printMenuTitle ("Export table");
	    do printMenuItems(
		"as CSV comma delimited","$SCRIPT/AdmExportCSV",
	        "as CSV semicolon delimited","$SCRIPT/AdmExportCSVS",
		"as TAB delimited","$SCRIPT/AdmExportTAB",
		"as OPTION array","$SCRIPT/AdmExportID"
		);

	    do printMenuTitle ("Import table");
	    do printMenuItems(
		"from CSV file","$SCRIPT/AdmImportForm",
		"rebuild from DEFAULT.tbl file (with processing!)","$SCRIPT/AdmRebuildFromTabForm"
		);

	    do printMenuTitle ("Close/open application");
	    do printMenuItems(
		"Close application for maintenance","$SCRIPT/AdmClose",
		"Open application after maintenance","$SCRIPT/AdmOpen",
		);

	    do printMenuTitle ("Other");
	    do printMenuItems(
		"Generate OPTION definition from field","$SCRIPT/AdmExtractCatForm",
		"Send serial email","$SCRIPT/AdmMailForm",
		"Try this database as guest","$SCRIPT/guest:/"
		);

	print "</TD></TR></TABLE>\n";
}

sub cgiAdmClose {

	do printHead("Closing application to enable maintenance");
	$message = <<EOM; #UK
This application is closed for maintenance.
Please try again at 14:00 GMT.
EOM

	if ($CGI{message}) {
	    open (H,">_cache/closed.ip") || do wbFail("Cannot open file closed.ip\n");
	    print H $ENV{REMOTE_ADDR};
	    close (H);
	    open (H,">_cache/closed.txt") || do wbFail("Cannot open file closed.ip\n");
	    print H $CGI{message};
	    close(H);
	    print "The database is now closed for all but users from $ENV{REMOTE_ADDR}\n";
	} else {
	    print <<EOM;
<FORM ACTION=$SCRIPT/AdmClose>
<BR>Enter a message to show to users:
<BR><TEXTAREA NAME="message" ROWS=5 COLS=50>$message</TEXTAREA>
<BR><INPUT TYPE=SUBMIT VALUE="Close for all but yourself">
</FORM>
EOM
	}
}

sub cgiAdmOpen {

	do printHead ("Opened the database for general public");

	unlink "_cache/closed.ip";
	unlink "_cache/closed.txt";
}

sub cgiAdmRebuildFromTabForm {

	do printHead ("Rebuild database from TBL file");

	print <<EOM;
<P CLASS=WARN>
This will first erase all .rec files and then it will
rebuild them from the _cache/DEFAULT.tbl file.
<FORM ACTION="$SCRIPT/AdmRebuildFromTab" METHOD=POST>
<P>Processing to do while rewriting. You should manipulate \$rec{} values.
<A HREF="$WBB{homeURL}/_cache/rebuild-actions.txt" TARGET="woda_other">Here</A>
are some previous rebuild actions
you might wish to cut and paste!
<BR>$INPUTON<TEXTAREA NAME=action COLS=60 ROWS=20></TEXTAREA>$INPUTOFF
<BR><INPUT TYPE=SUBMIT VALUE="Do it"> It will take time, don't panic!
</FORM>
<BR>
EOM
}

sub cgiAdmRebuildFromTab {

	do printHead ("Rebuilding database from tab file");

   	open (h,"_cache/DEFAULT.tbl") || do wbFail("Open of DEFAULT.tbl failed");
	@records = <h>;		# attn: newlines included !
	close (h);

	open (h,">_cache/DEFAULT.old");
	print h @records;
	close(h);

	print "<BR>DEFAULT.tbl backed up to DEFAULT.old\n";

	do admRebuild();
}

sub admRebuild {

	do wbReadRecordsFnames();

	# @records contains our database
	# fieldNames are the field names

	# delete the *.rec

	@files = &glob('*.rec');
	$count = 0;
	foreach $file (@files) {
	    unlink($file) && $count++;
	}

	print "<BR>$count files deleted\n";

	$todo = $CGI{'action'};
	$todo =~ tr/\r//d;

	open (H,">>_cache/rebuild-actions.txt");
	$date = &formatDate(time);
	binmode(H);
	print H "# --- $date from $ENV{REMOTE_ADDR}\n";
	print H "$todo\n\n";
	close(H);

	print "<BR>Actions logged to _cache/rebuild-actions.txt\n";
	print "<BR>Did this with each record:<BR><PRE>$todo</PRE>";

	$count=0;
	foreach $rec (@records) {
	    do wbTab2Rec($rec);
	    eval $todo;
	    $id = $rec{_id};
	    if ($@) {
	        print "<P CLASS=ERROR>$id: $@<BR>Failed and aborted!\n";
		last;
	    }
	    delete $rec{_id};

	    if ($WBB{key}) {
	        $x = $WBB{key};
	        $newId = eval $x;
	        $newId = &wbFixId($newId);
	    } else {
		$newId = $id;
	    }	

	    do wbWriteRec($newId) && $count++;
	}

	print "<BR>$count files written\n";

	print <<EOM;
<P><A HREF="$SCRIPT/AdmRebuildFromTabUndo">You can also UNDO what you just did.</A>
EOM

	do wbDatabaseChanged();
}

sub cgiAdmRebuildFromTabUndo {

	do printHead ("UNDO Rebuilding database from tab file");

   	open (h,"_cache/DEFAULT.old") || do wbFail("Open of DEFAULT.old failed");
	@records = <h>;		# attn: newlines included !
	close (h);

	open (h,">_cache/DEFAULT.tbl");
	print h @records;
	close(h);

	print "<BR>DEFAULT.tbl regenerated from DEFAULT.old\n";

	$CGI{action}='# UNDO';
	do admRebuild();
}


sub cgiAdmModifyStructureFrames {

	print <<EOM;
Content-type: text/html

<HEAD>
<TITLE>WODA - Modify Structure</TITLE>
</HEAD>
<FRAMESET ROWS="75%,*">
<FRAME SRC="$SCRIPT/AdmModifyStructureL" NAME="woda_sidebar">
<FRAME SRC="$SCRIPT/AdmModifyStructure" NAME="woda_right">
</FRAMESET>
EOM
}

sub cgiAdmModifyStructureL {

	do printHead ("Settings");
	$s = "<A HREF=$SCRIPT/AdmModifyStructure#_end TARGET=woda_right><B>proceed to the submit section</B></A>";
	print "Edit settings then $s\n";
	do admMeta();
	do admPrintWBBs(5);
	do wbSortFields();
	print "<P><B>Fields:</B><BR><TABLE><TR><TD> | \n"; 
	$i=1;
	foreach $f (@Fields) {
	    print "<A HREF=$SCRIPT/AdmModifyStructure#$i TARGET=woda_right>$f</A> | \n";
	    $i++;
	}
	for ($j=$i;$j<$i+3;$j++) {
	    print "<A HREF=$SCRIPT/AdmModifyStructure#$j TARGET=woda_right>field$j</A> | \n";
	}

	print "| $s </TD></TR></TABLE>\n";
}

sub cgiAdmModifyStructure {

	do printHead ("Edit Settings of a WODA Table");

	do admMeta();
	do wbSortFields();

	print "<FORM ACTION=$SCRIPT/AdmCreate METHOD=POST TARGET=woda_other>";
	print "<H2><A NAME=___wbase___></A>1. Database features</H2><TABLE CLASS=FORM WIDTH=\"100%\">\n";

	foreach $wbb (@MetaB) {
	    print &admMetaInput($wbb,'',$WBB{$wbb});
	}

	print "</TABLE><H2>2. Fields</H2>\n";

	$i = 1;
	foreach $f (@Fields) {
	    do admMetaInputField($i,$f);
 	    $i++;
	}

	do admPrintFieldForm ($i,3);		# and three new ones !

	if ($DBDEF) {
	    $fn = "$DBDEF.pl";
	} else {
	    $ENV{SCRIPT_NAME} =~ m|/([^/]*$)|;
	    $fn = "$1";
	    $fn = $fn . '.pl' unless $fn =~ m/pl$|cgi$/;
	}

	do admPrintFormEnd();
}

sub cgiAdmDaily {

	if ($CMDLINE) {
	    $x = $WBB{dbTitle};
	    print <<EOM;
Subject: $x: Daily Administration 
MIME-Version: 1.0
Content-type: text/html; charset=US-ASCII
Content-transfer-encoding: 7BIT

EOM
	}

	do wbDo ("cgiAdmClean");
	$HTMLFILE=1;  do wbDo ("cgiAdmExpire");
	$HTMLFILE=1;  do wbDo ("cgiAdmStatic");
	$HTMLFILE=1;  do wbDo ("cgiAdmAgentProcess"); # if $WBB{agentGroups};
}

sub cgiAdmStatic {

	# static page is what is after /cgi-bin/application
	# extention is htm
	# ?/|()/ --> _

        local ($selected);

	do printHead ("Making static pages and indexes");

	print <<EOM;
<B>Warning</B>: generated static pages will have links relative to
<A HREF=$SCRIPT>$SCRIPT</A>. If you are testing some new script
on a database which is served by a different script, the generated 
pages are all wrong!<P>
<P CLASS=WARN>There seem to be some problems when doing this under WINDOS. The page looks bad,
but the right things seem to get done anyway. Looks like Perl's select() function is not ported
100% onto WIN-DOS.
EOM

	# --- main title page

	# --- write static html pages for each record into htmlDir

	if ($WBB{spiderDir}) { 
	    $toc = "";
	    @allRec = &wbDir('.*rec$');
	    foreach $_ (@allRec) {
		($id) = m/(.*)\.rec$/;
	    	$hp = "$WBB{spiderDir}/$id.htm";
		$toc .= "<LI> <A HREF=$id.htm>$id</A>\n";
	        open (cache,">$hp") || do wbFail("Cannot open file $hp");
		print "<BR>Page $hp\n";
                $selected = select(cache);
	        $HTMLFILE=1;
		 $CGI{_id}=$id; $group=$Group; $Group='guest';
	          do wbDo ("cgiShow");
	          do wbDo ("printFoot");
		  delete $CGI{_id};$Group=$group;
	        $HTMLFILE=0;
	        close (cache);
		select($selected);
	    }

	    # write table of contents

	    $hp = "$WBB{spiderDir}/toc.htm";
	    open (cache,">$hp") || do wbFail("Cannot open file $hp");
	    print "<BR>TOC into $hp\n";
            $selected=select(cache);
	    print "<H1>Table of contents</H1>\n<UL>$toc</UL>\n";
	    close (cache);
	    select($selected);

	} else {
	    print "<P>No spider pages!";
	}

	# write the static home page (maybe with a link to the static)

	if ($WBB{generatedHomePage}) {
	    $hp = "$WBB{dataDir}/$WBB{generatedHomePage}";
	    open (cache,">$hp") || do wbFail("Cannot open file $hp");
            $selected=select(cache);
	    $HTMLFILE=1;
	    do wbDo("cgiHome");
	    do printFoot();
	    $HTMLFILE=0;
	    close (cache);
	    select($selected);
	    print "<BR>Wrote home page into $hp\n";
	}

	# touch the cached files here, generate above

	foreach $sort (DEFAULT,TIME,U1,U2,U3) {
	    next if ! $WBB{"sort;$sort"} && $sort ne 'TIME';
	    do wbUpdateTbl($sort,1);
	    print "<BR>Updated $sort.tbl\n";
	}

        return;
}

sub getRelatedURL {
	local ($otherDataDir) = @_;
	local ($i,$xgt,$url);

	%XENV = %ENV;	# save ENV
	$xgt = $>;
	undef %ENV;
	$i = &admGetEnv($otherDataDir);
	$url = "http://$ENV{SERVER_NAME}:$ENV{SERVER_PORT}$ENV{SCRIPT_NAME}";
	%ENV = %XENV;
	undef %XENV;
	$> = $xgt;
	return $url;
}

sub admGetEnv {
	local ($otherDataDir) = @_;
	local ($_,$name,$value,$i);

	$otherDataDir = '.' unless $otherDataDir;

	open (h,"$otherDataDir/_cache/env") || return 0;
	$i=0;
	while (<h>) {
	    chop;
	    $i++;
	    ($name,$value) = split (/=/);
	    if ($name eq 'UID') {
		$> = $value if $UNIX;
	    } else {
		$ENV{$name} = $value;
	    }
	}
	close h;
	return $i;
}

sub admSetEnv {

	local ($out);

	$out = "UID=$>\n";
	foreach $x ('SERVER_NAME','SERVER_PORT','SCRIPT_NAME') {
	    $out .= "$x=$ENV{$x}\n";
	}

	open (h,'>_cache/env') || do wbFail ("Cannot open ENV file");
	print h $out;
	close h;

	return $out;
}

sub cgiAdmPrintVars {

	do printHead ("Global Variables in WODA");
$var = <<'EOM';
$ADMINPASS::reserved
$ADMUSER::reserved
$AT::(W) what is UNIX at program
$Action::action currently executed
$BIGICONPAR::(W) IMG tags for big icons
$CHMOD::(W) what is UNIX chmod program
$CMDLINE::are we running from command line?
$CRONTAB::(W) where is crontab program
$CookieGroup::reserved
$CookiePass::reserved
$DIRMODE::(W) in what mode to create directories
$DISK::(W) on WINDOS, on which drive letter is WODA related stuff 
$DUMPABLEPERL::(W) where is a dumpable version of Perl
$GREP::(W) where is grep program
$Group::current group the user belongs to
$HTMLFILE::is output going to a file
$HTTP200OK::(W) add extra HTTPD messages to please some NT servers
$Help::(i)does the user requier a lot of help in forms
$HtmlHeaderPrinted::(i)was the HTML header already printed
$ICONPAR::(W) standard parameters for IMG tages of icons
$ICONURL::(W) URL of the icons
$InFrame::is output going into a frame
$JS::current JavaScript version supported by this browser
$MV::(W) where is the command to move files
$MyAction::reserved
$NOCACHE::reserved
$NO_CRYPT::Perl does not have crypt function
$NO_DIRTIMES::operating system does not show directory modification times
$NO_TIMES::Perl does not have times function
$PERL::where is Perl
$PERLV::version of Perl
$Page::name of the Page requested
$SCRIPT::URL of this script
$SENDMAIL::where is external sendmail program
$TESTCGIDIR::(W)directory to write generated definitions into
$TESTCGIURL::(W)URL of the above
$TMPDIR::temporary directory
$ThisRecordDate::data when this record was modified
$ThisRecordURL::URL of current record
@Toolbar::items to add into toolbar at the end of page
$UNDUMP::where is undump program
$UNIX::is this a UNIX system ?
$URLGroup::group of current user as set in the URL
$URLPass::password of current user at set in the URL
$User::username of current user
$VERSION::current version of WODA
$WBFile::name of this script
$WBHelp::URL of the WODA help files
$WBHome::home of WODA
$WBLang::lanugage of messages of this WODA
$WBLib::directory with library of subroutines
$WBPath::in which directory is this script
$WBProg::file in which is definition Perl script
$WBlanguage::language of messages in this WODA
$WBlanguageAuthor::who translated WODA to this language
EOM
	@var = split (/\n/,$var);
	print <<EOM;
<P>This table lists the global variables that are used
within the WODA engine. Variables marked with (W) are static
setings defined in the WODA code. Some of these variables are
defined at all times, others only during some operations.
<P><B>Within the database definition file, all these variables should
be considered read-only! Information about them is povided for power users
and for debugging purposes.
They are not cast in concrete and their names and values might change
in the future</B></P>
 
<TABLE BORDER=1>
<TR>
<TH>Variable</TH>
<TH>Description</TH>
<TH>Current Value</TH>
</TR>
EOM

	foreach $var (@var) {
	    ($name,$desc) = split(/::/,$var);
	    $value = eval("$name");
	    print <<EOM;
<TR>
<TD><B>$name</B></TD>
<TD>$desc</TD>
<TD>$value&nbsp;</TD>
</TR>
EOM
	}
	print "</TABLE>\n";
}

sub admPrintWBBs {

	local ($ncols) = @_;

	$ncols = $ncols || 4;

	undef @x;
	foreach $x (sort(@MetaB)) {
	    next if $MetaB{$x,what} eq 'H';
	    if (substr($MetaB{$x,uk},0,1) eq '*') {
		$mand = "<FONT COLOR=#FF0000><B>*</B></FONT>";
	    } else {
		$mand = "";
	    }
	    if ($WBB{$x} ne '') {
		$set = '<B>+</B>';
	    } else {
		$set = '';
	    }
	    if ($mand || ! $CGI{quick}) {
	        push (@x,"$set<A HREF=$SCRIPT/AdmModifyStructure#_b$x TARGET=woda_right>$x</A>$mand");
	    }
	}

	$x = &formatColumns($ncols,@x);
	print $x;
}


sub admConfAttrs {

	print "<H2>Legend - database attributes </H2><P>Stored in hash \$WBB\n" ; #UK
	print "<TABLE BORDER=0>";

	foreach $wbase (@MetaB) {
	    if ($MetaB{$wbase,what} eq 'H') {
		print <<EOM;
<TR  CLASS=MENUT VALIGN=TOP><TD>&nbsp;</TD>
<TD ALIGN=LEFT>
<B><U>$wbase</U></B>

</TD>
</TR>

EOM
		next;
	    }


	    $value = $MetaB{$wbase,uk} ; 
	    print <<EOM;
<TR VALIGN=TOP>
<TD ALIGN=RIGHT>
<B><A NAME="_b$wbase">$wbase</A></B>
</FONT>
</TD>

<TD>
$value
</TD>
</TR>
EOM
	}
	print "</TABLE>\n";

	print "<H2>Legend - field attributes </H2><P>Stored in hash \$WBF\n" ; #UK
	print "<TABLE BORDER=0>";

	foreach $wbase (@MetaF) {
	    $value = $MetaF{$wbase,uk} ; 
	    print <<EOM;
<TR VALIGN=TOP>
<TD ALIGN=RIGHT>
<B><A NAME="_f$wbase">$wbase</A></B>
</FONT>
</TD>

<TD>
$value
</TD>
</TR>

EOM
	}

	print "</TABLE>\n";

	print "<H2>Field Types Supported by WODA</H2>";

	do setTypes();
	@types = sort(keys(%FieldType));
	undef @val;
        foreach $type (@types) {
	    push (@val,$FieldType{$type});
	}

	print &formatNameVal(@types,@val);
}

sub admMA {
	local ($what,$name,$uk,$size,$deflt) = @_;

	"$what " =~ m/^(.)(.)/;
	$what = $1;
	$type = $2;

	if ($type eq 'r') {
	    $uk = "(regular expression) $uk";
	} elsif ($type eq 's') {
	    $uk = "(string expression) $uk";
	} elsif ($type eq 'l') {
	    $uk = "(logical expression) $uk";
	} else {
	    $uk = "(fixed value) $uk";
	}

	if ($what eq 'B' || $what eq 'H') {

	    $uk = &formatBaseDocs($uk,$name);

	    push (@MetaB,$name);
	    $MetaB{$name,what} = $what;
	    $MetaB{$name,uk} = $uk;
	    $MetaB{$name,size} = $size;
	    $MetaB{$name,dflt} = $deflt;
	    
        } elsif ($what eq 'F') {

	    $uk = &formatFldDocs($uk,$name);

	    push (@MetaF,$name);
	    $MetaB{$name,what} = $what;
	    $MetaF{$name,uk} = $uk;
	    $MetaF{$name,size} = $size;
	    $MetaF{$name,dflt} = $deflt;

	}
}

sub formatBaseDocs {

	local ($uk,$wbb) = @_;
#	$uk = &htQuote($uk);
	$uk =~ s|manual|<A HREF="$WBHome/man.htm">manual</A>|g;
	$uk =~ s/\^([a-zA-Z;]+)/<A HREF="#_b$1"><I>$1<\/I><\/A>/g;
	($t,$e) = split (/\nww/,$uk,2);
	if ($e) {
	    $e = &htQuote($e);
	    $e = "ww$e";
	    $e =~ s/\n/<BR>/g;
	    $e =~ s/ww=/\$WBB\{'$wbb'\}=/g;
	    $uk = "$t
Example:
<TABLE WIDTH=100%>
<TR><TD><TT>
$e
</TT></TD></TR>
</TABLE>";
	}
	return $uk;
}


sub formatFldDocs {

	local ($uk,$wbb) = @_;

	$uk = &htQuote($uk);
	$uk =~ s|manual|<A HREF="$WBHome/man.htm">manual</A>|g;
	$uk =~ s/\^([a-zA-Z;]+)/<A HREF="#_f$1"><I>$1<\/I><\/A>/g;
	($t,$e) = split (/\nww/,$uk,2);
	if ($e) {
	    $e = "ww$e";
	    $e =~ s/\n/<BR>/g;
	    $e =~ s/ww=/\$WBB\{\$x,'$wbb'\}=/g;
	    $uk = "$t
Example:
<TABLE WIDTH=100%>
<TR><TD><TT>
$e
</TT></TD></TR>
</TABLE>";
	}

	return $uk;
}

sub setTypes {

	return if defined %FieldType;

	$FieldType{'INPUT'} = "The defaul field type. A line of text.";
	$FieldType{'TEXTAREA'} = "Several rows of preformatted text. Adjust the size with ROWS=n COLS=m. Will be tagged as &lt;PRE&gt; unless P or BR tags are present"; 
	$FieldType{'HTMLAREA'} = "A paragraph of text or a whole tagged HTML document. Any formatting should be done in HTML. Adjust size with ROWS=n COLS=m";
	$FieldType{'OPTION'} = "An option list. Define options in the 'options' attribute. 'typePar' can be MULTIPLE and TREE. In the second case field will be offered for hierarchical browsing.";
	$FieldType{'LINKOPTION'} = "An option list where the options are keys from another table.
Define table's alias or dataDir in the 'options' attribute"; 
	$FieldType{'LIST'} = "A list of values. Values should be entered one per row.
Formatting and verification applies one per each item"; 
	$FieldType{'DATE'} = "Date type. Internally represented as yyyy/mm/dd.";
	$FieldType{'EMAIL'} = "An email address. By default rendered as mailto: HREF, checked to include '\@a'.";
	$FieldType{'URL'} = "A URL. By default rendered as A HREF";
	$FieldType{'FILE'} = "A file somewhere on the server, relative to homeURL.
E.g. picture, full text document ... By default rendered as link to that file.";
	$FieldType{'USERFILE'} = "Like FILE but database users can upload it to the server using the Netscape 2+ or Explorer 4+.";
	$FieldType{'IMAGE'} = "Like USERFILE but will be rendered on screen as an IMG.";
	$FieldType{'COMPUTE'} = "A field which is not stored in the database but is computed on the fly when record is read.";
	$FieldType{'BREAK'} = "A horizontal line to separate fields in forms and tabular output";
}

#
# admMeta ... defines database's meta information into MetaB and MetaF
#

# s = string expression
# l = logical expression
# r = regular expression
# c = constant !

sub admMeta {

    do setTypes();
    $types = join('|',sort(keys(%FieldType)));
    $types = '|' . $types;

    &admMA ('H','Essentials');

    &admMA ('B','dbTitle',<<EOM,40);
* database title
ww="Beach Club Members";
EOM

    &admMA ('B','about',<<EOM,100);
short descriptive text about the database
ww=<<END;
This database stores the members of the
Beach Club
END
EOM

    &admMA ('B','recordTitle',<<EOM);
title of one record. See also ^detailTitle.
ww="Club member"; 
EOM

    &admMA ('B','manager',<<EOM);
* name of database's manager (see ^managerEmail)
ww='Joe Smith';
EOM

    &admMA ('B','managerEmail',<<'EOM');
* ^manager's email
ww='jsmith@beachclub.com';
EOM

    &admMA ('B','dataDir',<<EOM);
* directory where data of the database is stored (without trailing slash!)
ww='/usr/local/www/htdocs/beachclub/members';
EOM

    &admMA ('B','homeURL',<<EOM);
* URL which denotes the same directory as the ^dataDir
ww='http://www.clubs.com/beachclub';
EOM

    &admMA ('Bs',"sort;DEFAULT",<<'EOM');
string to use for DEFAULT sorting of records. If undefined records will be sorted
by the first field.
ww='$rec{lastName} . $rec{firstName}';
EOM

    &admMA ('Bs',"format;DEFAULT",<<'EOM',100);
REPLACED WITH ^formatRowDEFAULT in WODA 3.4 and higher.
String, which formats DEFAULT
printout of one record in a listing. It will be placed between
&lt;OL&gt; tags. If undefined a table will be printed. 
ww='"$rec{firstName} $rec{initial} $rec{lastName}"';
EOM

    &admMA ('Bs','key',<<'EOM');
expression using $rec{} variables, which generates record key.
Default is a random number 4 hex digits long. Record key is
used as file name for the .rec files.
ww='$rec{lastName}';
EOM

    &admMA ('H','Database home page');

    &admMA ('B','homePage',<<EOM);
Name of a HTML file which is the homepage of the database (in ^homeURL) unless
contains a / in which case relative to server root).
If empty, the database's home will be the page automatically generated by
this script, not an HTML file.
ww='homepage.htm';
ww='/index.htm';
EOM

    &admMA ('B','generatedHomePage',<<EOM);
WODA can automatically generate a .html file for the database
home page. Define here into which file it should create it (relative to ^dataDir.
Can be the same as ^homePage in which case the generated .html will replace
what you wrote in it. Mainly used to speed up the delivery of the database's
home page.
ww='index.htm';
EOM

    &admMA ('H','Speed up searches');

    &admMA ('B','grepBigger',<<EOM);
If nonzero and if \$GREP WODA variable is defined,
UNIX's grep will be used to speed up searches if
the size of data is larger than this number of bytes. Set to
500000 or more. See also ^searchCache if you want to
speed up searches.
EOM

    &admMA ('B','cacheExpire',<<EOM,'0|1|2|4|6|8|12|24|48|96|168');
in how many hours do cached data expire. WODA uses cacheing of data to speed up searches.
This value in fact means that it may take at most this many hours before entered record
is found. 0 means no cacheing.
EOM

    &admMA ('B','searchCache',<<EOM);
If nonzero WODA will cache search results in the _cache
directory. Files will be named records*.txt. In the future
this parameter will determine how cache will be cleaned. 
EOM

    &admMA ('H','Automated maintenance');

    &admMA ('Bs','afterTableModify',<<EOM);
Expression (Perl statement or program) that is
exectuted after a table is modified.
ww='`/usr/local/bin/execHtm whatsnew.htm`';
EOM

    &admMA ('B','maintenancePeriod',<<EOM);
Every how many hours should the automatic
maintenance of the database take place (or 0 to disable). HTTPD must be
allowed to use UNIX's 'at' command. 
If you set up Angie, this should be once a day. If the database 
is little used, use cron instead.
ww=24;
EOM

    &admMA ('Bs','deleteAfter',<<EOM,2);
delete records older than this many days (0=never)
EOM

    &admMA ('H','Shopping basket');

    &admMA ('B','basketName',<<EOM,100);
If defined, WODA will allow adding to a shopping basket in all
search and similar pages. This is not only usefull for shopping but
for compiling a list of relevant found records. This can later be 
printed out together etc. The value entered should fit nicely after
"add to " ... e.g. "favorites","shopping list","your personal selection"
etc. Baskets are bound to end user's IP and have a lifetime of
30 minutes.
ww="My favorite members";
EOM

    &admMA ('H','More ways to sort search results');

    foreach $p ('U1','U2','U3') {
       
      &admMA ('B',"sortName;$p",<<EOM,20);
name of $p sorting
EOM

      &admMA ('Bs',"sort;$p",<<EOM);
string to use for $p sorting of records. See ^sort;DEFAULT for details.
EOM
    }

    foreach $p ('DEFAULT','1','2','3') {

      &admMA ('H',"More ways to format search results - type $p");

      &admMA ('B',"formatName$p",<<EOM,20);
This and next 3 setting define how found records
are printed out. Here the name of this format is
defined and will be used in menues and pull-downs.
EOM

      &admMA ('B',"formatHead$p",<<EOM);
Next 3 settings define how a list of found
records is layed out. First the formatHead
is printed, then, for each record, formatRow,
and finally, ^formatFoot.
ww='<TABLE>';
EOM

      &admMA ('Bs',"formatRow$p",<<'EOM');
See ^formatHead for details. The following variables
can be used:
<UL>
<LI>$ThisRecordURL ... URL of the found record.
<LI>$ThisRecordDate ... date when the record was last modified.
<LI>$ThisRecordIcons ... system action acions for this record.
<LI>$ThisRecordBasket ... checkbox for the shoppingBasket.
<LI>$ThisRecordMatches ... numeric value of the relevance of this record.
</UL>
ww='"<TR>
<TD><A HREF="$ThisRecordURL">$rec{firstName}</A></TD>
<TD>$rec{lastName}</TD>
</TR>
"'
EOM

      &admMA ('B',"formatFoot$p",<<EOM);
What is printed after all found records.
ww='</TABLE>';
EOM
    }

    &admMA ('H','Change the look of the Detail page');

    &admMA ('Bs',"detail",<<EOM,100);
how to format a page with one record. If undefined the fields will
be printed in default format - a two column table. See also ^detailTitle.
EOM

    &admMA ('Bs','detailTitle',<<'EOM',100);
string expression to generate as title on the default detail page
Use $pgTitle, $dbTitle, $homeURL, $scriptURL, which contain page title
(^pageTitle), database title (^dbTitle),
database's home URL (^homeURL) and stript's home URL.
ww='"Full details of $rec{firstName} $rec{lastName}"';
EOM

    &admMA ('H','Change the appearance of every page');

    &admMA ('B','style',<<EOM,100);
Stylesheet to apply on pages generated.
Value of this field will
be inserted between &lt;STYLE&gt; tags.
View source to see which CLASSes are used.
If empty, the default style sheet will be applied.
Set to '/* */' to insert an empty style sheet.
EOM

    &admMA ('B','pageBody',<<EOM);
parameters for the HTML's BODY tag
ww='BGCOLOR=#000000';
EOM

    &admMA ('B','pageHead',<<EOM,100);
text to display on every page top above ^pageTitle and below BODY tag
EOM

    &admMA ('B','pageHeadIcon',<<EOM,100);
text to display on every page inside the
default generated table for the title.
Good place to put LEFT or RIGHT aligned IMG tags.
EOM

    &admMA ('B','pageFoot',<<EOM,100);
text to diplay at the end of every page, below
the default generated toolbar.
EOM

    &admMA ('B','formFoot',<<EOM,100);
text to diplay at the end of every entry form
EOM

    &admMA ('B','JavaScript',<<EOM,4);
Maximum JavaScript version that should be used
to enhance the generated pages. Set to 0 to disable JavaScript.
Keep empty to let the script determine the JavaScript version
that a browser can support.
EOM

    &admMA ('H','Make big changes to header and footer of every page');

    &admMA ('Bs','pageTitle',<<'EOM',100);
string expression to generate on every page top below pageHead
You can use the following variables:
<UL>
<LI>$pgTitle - the title of the page
<LI>$dbTitle - the value in ^dbTitle
<LI>$homeURL - URL of the database's home page (^homeURL)
<LI>$scriptURL - URL of this script,
</UL>
If not set, something like this is printed
as default:
ww='"
<H1>
<SMALL>
<A HREF=$homeURL>$dbTitle</A>
</SMALL>
<BR>
$pgTitle
<HR>
</H1>
"'
EOM

    &admMA ('Bs','pageEnd',<<'EOM',100);
string expression which generates whatever
is printed at the end of every page, just above ^pageFoot.
Array @Toolbar conains the elements that should
be placed into the toolbar. If not set, something
like this is printed as default:
ww='
$x = join("</TD><TD>",@Toolbar);
"<TABLE CLASS=TOOLBAR><TR><TD>$x</TD></TABLE";
';

    &admMA ('H','Add to tooolbars');

    &admMA ('B','toolbarText',<<EOM,60);
The default toolbar has some system icons on the
left and "powered by WODA" icon on the right.
In between is a wide empty cell. This text will be
printed in it.
ww='(c) Blinky Bill 1993';
EOM

    &admMA ('B','toolbar',<<EOM,100);
Replaced pageToolbar, showToolbar and searchToolbar
in future versions of WODA. Conatains a table with space-separated 
columns and several rows.
The left column contains a pattern to match against
the action part of the URL (Search, Add, Home ...).
The right contains a string expression (variables can be used!)
to add into one cell of the toolbar table. In the below example, 
the first item is added to Add pages only, the second one to all pages.
Third item calls a subroutine to generate the string.
ww=<<END;
Add	"<IMG SRC=help.gif> help"
.	"(c) 2001 The Oddisey Group"
Edit	&editToolbar()
END
EOM

    &admMA ('H','Add to menus on the Home page');

    &admMA ('B','userMenuBrowse',<<EOM,100);
comma separated list of text,url to add to Browse menu. One per row!
EOM

    &admMA ('B','userMenuFind',<<EOM,100);
comma separated list of text,url to add to Find menu. One per row!
ww='Search in member websites,http://www.theclub.com/harvest?search';
EOM

    &admMA ('B','userMenuAdd',<<EOM,100);
comma separated list of text,url to add to Add menu. One per row!
EOM

    &admMA ('B','userMenuOther',<<EOM,100);
comma separated list of text,url to add to other menu. One per row!
EOM


    &admMA ('H','Custom browse options');

    &admMA ('Bs','tree',<<EOM);
expression which creates database subtitles for browsing. It takes
some time to create this index therefore all 'trees' are cached. Changing this value
will not require a cache update. After change manually clear the *.3.* files from _cache!
For most applications, ^tree is an overkill. See TREE as ^typePar if
tree data comes from one field only.
ww="\$rec{category};\$rec{subcategory}";
EOM

    &admMA ('Br','treeSplit',<<EOM);
pattern which splits '^tree' into category and subcategory.
ww=';';
EOM

    &admMA ('B','AZindex',<<EOM,100);
Table, which defines how A-Z indexes of the database are defined.
Each row defines one A-Z index. The columns are (1) ID (a word which defines
a name of the A-Z index, (2) the comma separated list of field names which are used to
provide the words for the A-Z inndex and (3) the rest is a nice textual description of
the A-Z index.
ww=<<END;
byname	lastName,firstName	Index of members by last and/or first name.
bystate	state	Index of members by state
END
EOM

    &admMA ('B','AZnot',<<EOM,100);
List of words which should not be included in the ^AZindex. 
The words should be white-space separated. Regular expressions may be used.
ww='a the is at';
EOM

    &admMA ('H','Changing headers and footers on some pages');

    foreach $p ('Home','Search','Add','Changed','Store','Edit','NewForm','AdvancedSearchForm','SearchIDForm','AdmMenu') {

      &admMA ('B',"head;$p",<<EOM,100);
text to diplay on top of page $p
EOM

      &admMA ('B',"foot;$p",<<EOM,100);
text to diplay at the end of page $p
EOM
    }

    &admMA ('H','Icons');

    &admMA ('B','iconURL',<<EOM);
URL of a directory where WODA system icons are kept. No trailing slash!
EOM

    &admMA ('B','iconOpen',<<EOM);
Base name for the icons that denote found item in a database. The dafault is 
'open' and icons open1.gif ... open4.gif are used in search listings etc.
You can also set it to floppy, paper, mail, face or any other graphics set you created.
ww='face';
ww='star'; 
EOM

    &admMA ('H','Relational features');

    &admMA ('B','tables',<<EOM,100);
table with columns ALIAS PROGRAM DATADIR which defines
other WODA databases which are somehow related to this one. ALIAS
is the logical name, program is the name of the database definition file
and DATADIR is the name of the database's data direcory. If this field contains
only one word then it is interpreted as the filename of the file which
contains such a table, so that several WODA databases can share the same
definitions. Alternatively, this field can be defined in ^requireFile
shared by many tables.
ww=<<END;
members	/usr/www/cgi-bin/members /usr/www/data/members
states	/usr/www/cgi-bin/states /usr/www/data/states
END
EOM

    &admMA ('B','requireFile',<<EOM);
file with add-in subroutines to be require-ed by Perl. Absolute path suggested!
Tyipcally used to store the ^tables and ensure consistent
formatting of several tables of a relational application.
ww='/usr/www/cgi-bin/common.pl';
EOM

    &admMA ('H','Group based security');

    &admMA ('B','groups',<<EOM,100,$ADMUSER);
How to map hosts into groups of users. 
Table with three tab separated columns: group-name, host-pattern, password.
See manual for more information. A fried is anyone comming from the set of IP addresses
listed or anyone who knows password tukan. An enemy is anyone else; also people from the
193.2.92 net who supply password hateit. Special users are those knowing password barbara,
no matter the IP.
ww=<<END;
friends	193.2.92.*	tukan
enemies	.	hateit
special #	barbara
END	
EOM

    &admMA ('B','rights',<<EOM,100);
Who is alowed to do what.
Table with with three tab
separated columns allow/deny,group (from ^groups),action-pattern.
See manual. See ^ownerField for definition of two magic groups. Below, freinds can
Add or Edit stuff. Special can subscribe to Agent searches. Enemies are denied everything. 
ww=<<END;
allow	friends	Add|Edit
allow	special Agent.*
deny	enemies	.*
END
EOM

    &admMA ('Bs','userScope',<<EOM,10);
To pass usernames and passwords, cookies are used. By default,
cookies are only set for one table at a time and as a result
a user must log in to several related tables separately. This
string should be set to the local part of the URL for which
cookies should be valid, starting with a slash. E.g. /cgi below will
pass usename and password to all cgi programs on the same server. 
ww='/cgi';
EOM

    &admMA ('H','User based security');

    &admMA ('B','userTable',<<EOM,10);
An alias of a table from ^tables field that
contains information about the users of this table.
Username will be the ^key as defined in the ^userTable.
Password of the user will be the same as the password
used lock a record in the ^userTable. The user will
belong to a group given in ^userTable's field called 'group', or
to the default group given in the ^userTableGroup field
here or to group 'guest' (in that order).
See manual.
ww='members';
EOM

    &admMA ('B','userTableGroup',<<EOM,10);
Group (from ^groups) to which all users
defined in table ^userTable belong, unless
the ^userTable contains field named 'group' which
overrides this default. If undefined, the users defined
in ^userTable default to group 'user'.
ww='friends';
EOM

    &admMA ('Bl','userAllow',<<EOM);
Logical expression, based on data in table pointed to by ^userTable
that evaluates to true, if a given user is allowed to log into
this database or to false, if not. If empty or equal to 1
anyone is allowed to login. Otherwise admin can check applicants
before letting them use the database for example (below),
by setting the status field to OK. It would make sense to set 
^modifies of status to 'admin'.
ww='$rec{status} eq "OK"';
EOM

    &admMA ('Bs','ownerField',<<EOM,10);
Name of field that containes the
username of the owner of this record.
If the value in this field is the same as
the username of the logged in user (one from ^userTable)
the ^rights, ^sees and ^modifies for a magic group 
'owner' will apply in the context of this record.
If the value of this field is '0' or ''
the rights for magic group 'public' will apply. This setting lets you
build databases where records are protected by user,
not by password, and a combination of both.
ww='recordOwner';
EOM

    &admMA ('H','Special protection of records');

    &admMA ('B','filter',<<EOM,100);
Hide some records from some ^groups. Table with two tab separated columns. In the first is
a name of a group as defined in the ^groups attribute. In the second is the
search condition which will be silently added to any search any user from this group 
performs. The example below only records that contain the word "abracadabra" will
be found.
ww='guest	+abracadabra';
EOM

    &admMA ('Bl','hideUnless',<<'EOM',100);
^filter prevents record to be found. ^hideUnless prevents them
to be shown if someone happens to know the id and keys in
the URL. Only records for which this expression evaluates
to TRUE will be displayed.
ww='$Group eq "users" && $rec{_id} eq $User';
EOM

    &admMA ('B','hideUnderscore',<<EOM,1);
if set to 1, system fields _from, _at and _id will
be hidden in the default detail screen and tables.
EOM

    &admMA ('H','Limiting number of found records');

    &admMA ('B','dfltHits',<<EOM,5,$WBB{dfltHits});
default number hits per page in searches
EOM

    &admMA ('B','maxHits',<<EOM,5,$WBB{maxHits});
maximum allowed hits per page in searches. On the advanced search page,
users may ask for up to this many hits per page.
EOM

    &admMA ('H','Support for non-english languages');

    &admMA ('B','language',<<EOM,2,'uk');
* User interface language. Enter a two letter language code (English=UK, Slovenian=SI ...).
You must have the appropriate woda-xx.pl libray installed, to support your language.
ww='UK';
EOM

    &admMA ('B','intlCharset',<<EOM,10);
character set used in pages of the database
ww='ISO-8859-1';
ww='WINDOWS-1250';
EOM

    &admMA ('B','intlCollate',<<EOM);
how to sort intl. characters. Many space separated strings like
e&#234;&#233; o&#246;&#244; which mean that &#234;&#233; should be sorted after
e, &#246;&#244; after o ... Define on lower case only!
EOM

    &admMA ('B','intlLower',<<EOM);
how to convert uppercase international letters into lower case
or other character equivalences in sorting.
Two space separated strings must be defined - the first are upper case letters, 
the second corresponding lower case ones: like &#234;&#233;&#234;&#233; eeuu 
In this case they will be sorted as if they were equivalent to e-s and u-s
EOM

    &admMA ('B','intlAscii',<<EOM);
how to convert lower case international letters into corresponding ASCII ones
(eg. &egrave; into e).
Two space separated strings must be defined - the first are the non-ascii
characters, then are the corresponding ascii ones. Both strings must be equal size!
EOM

    &admMA ('H','Making application friendly for AltaVista and co.');

    &admMA ('B','spiderDir',<<EOM);
directory where system generates HTML pages which web robots should find (without trailing slash!).
If undefined no such files will be generated. One .htm file per record will be generated
plus file toc.htm.
ww='/usr/local/www/htdocs/beachclub/robots';
EOM

    &admMA ('B','spiderURL',<<EOM);
URL which denotes the same directory as the ^spiderDir.
ww='http://www.clubs.com/beachclub/robots';
ww='/beachclub/robots';
EOM

    &admMA ('H','Other options');

    &admMA ('B','adFile',<<EOM);
file with information about the ads to run in page headers. Ads
are defined in a text file with tab separated columns URL ALT-TEXT URL-OF-IMAGE
EOM

    &admMA ('B','ascii',<<EOM,1,1);
use readable ascii to store records (1=yes,0=no) This format will be phased out in the future.
Do not use it for new databases!
EOM


    ### --- field level data --- ###

    &admMA ('Fl','',<<EOM,'','1;');
* Unnamed atribute. Expression which validates the field value in \$_. 
Keep 1; if anything goes.
In BREAK fields text of the break.
EOM

    &admMA ('F','type',<<EOM,$types);
* Field type.
ww='OPTION';
EOM

    &admMA ('F','cond',<<EOM);
Validation expression written in plain English (or another language).
ww='Should not be empty!';
EOM

    &admMA ('F','head',<<EOM);
Name of the field for table headings. If undefined, field name is used.
ww='Supported operating system';
EOM

    &admMA ('F','p',<<EOM);
Short prompt for field, shown above field.
ww='Check all operating systems on which your software works';
EOM

    &admMA ('F','help',<<EOM,100);
Help text on field input, shown below field. Usually much longer than prompt text.
ww='Do not check all systems if it is a Java program. Just click next to Java, you dummy.';
EOM

    &admMA ('F','d',<<EOM);
Default value. If it includes a semicolon followed by a newline or if it starts with an & it will evaled. 
ww='WIN98';
ww='
$User;
';
EOM

    &admMA ('F','typePar',<<EOM);
Additonal field parameters. By default these are added to the INPUT (e.g. SIZE=n),
TEXTAREA (e.g. ROWS=x COLS=y) or SELECT tags (MULTIPLE).
Special values are CONTINUE (show next field on the same row in form),
HIDDEN (makes an INPUT field hidden),
RADIO and CHECKBOX (modify OPTION
typed fields from pulldowns into
checkbox or radio button format).
TREE makes sense with OPTION or LINKOPTION typed fields.
It will use the field for hierarchical browsing of
the database. ^options must be like europe:italy:rome, that is,
categories and subcategories separated by colons.
ww='CHECKBOX MULTIPLE';
EOM

    &admMA ('F','options',<<EOM,100);
* Allowed options for OPTION typed fields either on a same line separated by |
or one per line. If the options are in one-per row format, then the row 
can have several columns separated with TABs. The first column is used a
a value to be stored in the database. All others are shown on screen to make
the selection clearer. 
ww=<<END;
	(unknown)
WIN3.1
WIN95
WIN98	(also includes WIN2000)
WINNT
MAC
LINUX
FreeBSD
HP-UX
Java
Excell
Word
END
EOM

    &admMA ('F','into',<<EOM);
(1) dataDir or alias of the related database.
Keys of this database will be extracted.
(2) If this field starts with an & character it will be evaluated.
The result of the program should be formatted as the ^options setting above.
This lets you add more information about the selection. Typically you would use
&ROWS function.
ww='platforms'; # (1)
ww='&ROWS("platforms","_id,name")'; # (2)
EOM

    &admMA ('Fs','picture',<<'EOM');
expression which nicely formats field value in $_
Use &QRY() and &FLD() functions to relate to other databases.
Below we display an icon instead of text.
ww='"<IMG SRC=/imgs/platforms/$_.gif>"';
ww='"<B>$_</B>"';
EOM

    &admMA ('F','srt',<<EOM,0);
order of field in forms.
EOM

    &admMA ('F','sticky',<<EOM);
Leave empty (default) or set to 1 to make the value entered here
default next time the same user enters this form.
E.g. email addresses could be made sticky.
Set to any value including a / to set the path= variable in HTTPD-COOKIE header.
ww='1';
ww='/';	# for all woda generated forms with such field on this server
ww='/cgi/data';	# for all woda generated forms with such field within /cgi/data directory
EOM
	
    &admMA ('Fr','modifies',<<EOM);
| separated list of ^groups allowed to modify this field (or empty for all)
ww='friend|special';
EOM

    &admMA ('Fr','sees',<<EOM);
| separated list of ^groups allowed to see the value of the field (or empty for all)
ww='friend|special|guest';
EOM

}

sub admMetaInput {

	local ($name,$number,$value) = @_;
	
	$nav = '';
	# $nav = "<A HREF=#_end>[!]</A>\n";
	if ($number eq '') {		# database

	    if ($MetaB{$name,what} eq 'H') {
		$out = <<EOM;
<TR VALIGN=TOP CLASS=MENUT>
<TD>$name</TD></TR>
EOM
		return $out;
	    }

	    $prompt=$MetaB{$name,uk} ; 
	    $size  =$MetaB{$name,size};
	    $dflt  =$MetaB{$name,dflt};
	    $bookmark = "<A NAME=\"_b$name\">&nbsp;</A>";
	    $spc="<BR>";
	    $nameplus='';
	} else {			# field
	    $prompt=$MetaF{$name,uk} ; 
	    $size  =$MetaF{$name,size};
	    $dflt  =$MetaF{$name,dflt};
	    $bookmark = '';
	    $spc='';
	    $nameplus="[$number]";
	}

	$dflt = $value if $value ne '';
	$dflt = &htQuote($dflt);

# $prompt =~ s/\|/, /g;

	$size = 50 if $size eq '';

	unless ($prompt =~ m/^\*/) {
	    if ($CGI{quick}) {
		return '';
	    }
	} else {
	}

	$out = <<EOM;
<TR VALIGN=TOP CLASS=FORM>
<TD ALIGN=RIGHT VALIGN=TOP> $bookmark <B>$name $nameplus</B> $nav </TD><TD ALIGN=LEFT>
EOM


	$nn = '"' . $name . $number . '"';

	if ($size =~ m/\|/) {		# optionlist
	    @opts = split (/\|/,$size);
	    $out .= "<SELECT NAME=$nn SIZE=1>\n";
	    foreach $opt (@opts) {
		if ($opt eq $dflt) {
		    $out .= "<OPTION SELECTED>$opt\n";
		} else {
		    $out .= "<OPTION>$opt\n";
		}
	    }
	    $out .= "</SELECT>\n";

	} elsif ($size eq '0') {	# reserved
	    return '';

	} elsif ($size > 80) {
	    $out .= "$INPUTON<TEXTAREA ROWS=5 COLS=50 NAME=$nn>$dflt</TEXTAREA>$INPUTOFF\n";

	} else {			# one liner

	    $out .= "$INPUTON<INPUT SIZE=$size NAME=$nn VALUE=\"$dflt\">$INPUTOFF\n";


	}
	$out .= <<EOM;
<BR>
<FONT SIZE=2>
$prompt
</FONT>
$spc $spc $spc $spc $spc
</TD></TR>
EOM

	return $out;
}

sub admMetaOutput {

	local ($name,$value)=@_;

	$value =~ s/'/'."'".'/g;		# make sure ' does not cause
						# sytax errors
	$value =~ s/\r\n/\n/g;			# CR-LF into LF only ! 

	return "$name = '$value';\n";
}

sub admPrintFieldForm {
	local ($start,$num) =@_;

	for ($i=$start;$i<$start+$num;$i++) {
	    do admMetaInputField($i);
	}
}

sub admMetaInputField {

	local ($i,$f) = @_;

	print <<EOM;
<BR><BR>
<A NAME=$i>
</A>
<TABLE CLASS=FORM>
<TR CLASS=TITLE>
<TD ALIGN=RIGHT><B>Field $i</B></TD>
<TD><INPUT SIZE=20 VALUE="$f" NAME="_f$i"></TD>
</TR>
EOM

	foreach $mf (@MetaF) {
	    $value=$WBF{$f,$mf};
	    $value=$WBF{$f} if $mf eq '';

	    print &admMetaInput($mf,$i,$value);
	    print "\n";
	}

	print "</TABLE>\n";
}

sub admPrintFormEnd {

	print <<EOM;
<P><A NAME=_end></A>
<INPUT TYPE=SUBMIT VALUE="Create database definition">
<BR>into file <TT>$TESTCGIDIR/</TT><INPUT NAME="filename" VALUE="$fn" SIZE=20>
<BR>or (if empty) print the definition into the browser.
<P>
<B>Warning!</B> make sure that the new definition
does not replace the definition currently used by the end-users of the database.
New definition is written if it is found to be syntactically correct and if the
web server has the right to write it.  
EOM
</FORM>
}

sub cgiAdmPrintCGIAPI {

	do printHead ("CGI functions");
	print <<EOM;
Below are all cgi functions defined in WODA.
They can be called as $SCRIPT/Name where name is
a listed function. They are deliberately not linked, because
most should not be called out of context and without
proper parameters. The parameters are listed in braces.
The list is machine generated and therefore usually incomplete.
EOM

	do "$WBPath/api.pl";
	print $cgis;
}


sub cgiAdmPrintPerlAPI {

	do printHead ("Perl functions");
	print <<EOM;
<P>These are Perl functions that can be called in
Woda parameters that allow expressions. In Perl you call functions
like this:<PRE>
	&functionName(parameter1,parameter2)
</PRE>
<P>If you use the .pm version of WODA these function are
in a package, typically WODAUK, so you call them like:
<PRE>
	&WODAUK'functionName(parameter1,parameter2)

	or

	&WODAUK::functionName(parameter1,parameter2)

</PRE>
EOM
	do "$WBPath/api.pl";
	print $xxxs;
}

sub cgiAdmMailForm {

	do printHead ("Send serial email");
	print <<EOM;
<B>HELP:</B> Fill in the fields. Use \$rec{'fieldname'} notation
to denote field data e.g. if the email address is in the 'email'
field, write \$rec{'email'} into the To field. Use normal search syntax
in the search field. Use preprocessing field to define any processing
to be done before a record is composed (e.g. &PIC() to get nicely formatted
values of fields ...

<FORM ACTION=$SCRIPT/AdmMailSend METHOD=POST>
EOM

	$me = $CGI{from} || $WBB{managerEmail};
	$em = $CGI{to} || '$rec{email}';

	@prompts = ('Search:','Preprocessing:','From:','To:','Subject:','Message:','Where-to:');
	@flds = (
"<INPUT NAME=search SIZE=40 VALUE=\"$CGI{search}\" >",
"<TEXTAREA WRAP=\"PHYSICAL\" NAME=process ROWS=5 COLS=60>$CGI{process}</TEXTAREA>",
"<INPUT NAME=from SIZE=40 VALUE=\"$me\">",
"<INPUT NAME=to SIZE=40 VALUE=\"$em\">",
"<INPUT NAME=subject SIZE=60 VALUE=\"$CGI{subject}\">",
"<TEXTAREA WRAP=\"PHYSICAL\" NAME=message ROWS=15 COLS=60>$CGI{message}</TEXTAREA>",
"<SELECT NAME=where><OPTION>SCREEN<OPTION>MAIL</SELECT>"
);

	print &formatNameVal (@prompts, @flds);
	print <<EOM;
<INPUT TYPE=SUBMIT VALUE="Send">
<INPUT TYPE=RESET VALUE="Reset">
EOM
}

sub cgiAdmMailSend {

	$CGI{to} =~ s/\@/\\\@/;
	$CGI{from} =~ s/\@/\\\@/;

	do printHead ("Sending Serial Mail");
	$x = &wbSearch  ($CGI{search},'','','TAB',0,99999999);

	print "Sending $x messages.<P>\n<OL>";

	foreach $id (@ids) {

	    print "<HR>$id\n";

	    do wbParseFile("$id.rec",1);

#	print "<PRE>";
#	    print join (',',@fieldNames);
#	    $item =~ tr/\t/,/;
#	    print "\n$item";
#
#	    print join ("<BR>\n",%rec);
#
#	    last;

	    eval($CGI{process});
	    $to      = eval ('"' . "$CGI{to}"      . '"');
	    $from    = eval ('"' . "$CGI{from}"    . '"');
	    $subject = eval ('"' . "$CGI{subject}" . '"');
	    $message = eval ('"' . "$CGI{message}" . '"');
	    $mess=<<EOM;
From: $from
Cc: $from
To: $to
Subject: $subject

$message
EOM

	    if ($to) {
		# OK
	    } else {
		print "No destination address\n";
		next;
	    }

	    if ($CGI{where} eq 'MAIL') {
	        do agentMail ($mess) ;
	        print "<LI>To: $to\n";
	    } else {
		print "<PRE>$mess</PRE>\n";
	    }
	}

	print "</OL><BR>Finished\n";
}

sub formatTmpWinOpen {
	local ($url,$name) = @_;

	$name = $name || 'woda_other';

	if ($url =~ m/LoginForm$/ && $url =~ m/:/) {
	    $name = '_self';
	    $url =~ s|/[^/:]+:[^/]*||;
	    $url .= '?win=self';
	    return <<EOM;
<A HREF="$url" TARGET="$name">
EOM
	}

	if ($JS >= 1.2) {
	    return <<EOM;
<A HREF="#"
onClick='
window.open("$url","$name","scrollbars=yes,resizable=yes,toolbar=no,width=400,height=400");'
>
EOM
	} else {
	    return <<EOM;
<A HREF="$url" TARGET="$name">
EOM
	}
}

sub formatTmpWinClose {

	local ($msg1,$msg2);
	$msg1 = "Done. Click here to close."; #UK
	$msg2 = "Close this window and <B>reload</B> the other one to see the change."; #UK
	if ($JS>=1.2) {
	    $NOFOOT=1;
	    return <<EOM;
<FORM>
<INPUT TYPE="button" VALUE="$msg1" SIZE=20
OnClick='window.opener.document.location.reload();window.close()'
></FORM>
EOM

	} else {
	    return "<P>$msg2";
	}
} 

# CODE for BASEKT SUPPORT
# - BasketAdd?id=ID&num=2
# - BasketList
# - BasketEdit?id1=id1&no1=no1...
# - BasketSearch?searchParameters
# - basket file per IP number at /_basket/
# - id<TAB>number

sub cgiBasketAddOne {

	do readBasket();
	push (@BasketID,$CGI{_id});
	push (@BasketNO,$CGI{num}||1);
	do writeBasket();
	do readBasket();
	do printBasket();
}


sub cgiBasketAdd {

	do readBasket();
	foreach $key (keys(%CGI)) {
	    if ($key =~ m/^id(.*)/) {
		if ($CGI{$key} eq 'on') {
		    push (@BasketID,$1);
		    push (@BasketNO,1);
		}
	    }
	}
	do writeBasket();
	do printBasket();
}

# fills $BasketID and $BasketNO and returns numbers of items in basket

sub readBasket {

	local (@x);

	undef @BasketID;
	undef @BasketNO;
	undef @lines;

	$file = &basketFile();

   	@x = stat($file);
	if ($x[9]<(time-3600)) {
	    # selection expired
	    unlink $file;
	} else {
	    open (h,$file);
	    @lines = <h>;
	    close (h);
	}

	$i=0;
	foreach $line (@lines) {
	    chop($line);
	    ($id,$no)=split(/\t/,$line);
	    $BasketID[$i]=$id || $line;
	    $BasketNO[$i]=$no || 1;
	    $i++;
	}
	return $i-1;
}	

# writes Basket to disk

sub writeBasket {
	local (%printed,$file,$i,$ii);

	$file = &basketFile();
	if ($#BasketID < 0) {
	    unlink ($file);
	    return 0;
	} else {
	    open (h,">$file");
	    for ($i=0;$i<=$#BasketID;$i++) {
		$ii = $BasketID[$i];
		if (! $printed{$ii}) { # remove duplicates
		    print h $ii . "\t" . $BasketNO[$i] . "\n" if $BasketNO[$i] > 0;
		    $printed{$ii}=1;
		}
	    }
	    close (h);
	}
	return $i+1;
}

# returns name of basket file
sub basketFile {
	local ($ip);
	unless (-d '_cache/basket') { mkdir ('_cache/basket',$DIRMODE) };
	$ip = $ENV{'REMOTE_ADDR'};
	$ip =~ tr/\./x/;
	return ("_cache/basket/$ip");
}

sub cgiBasketShow {
	if ($CGI{editable}) {
	   $ed=1;
	} else {
	   $ed=0;
	}
	do printBasket($CGI{'format'},$ed);
}

# prints basket as HTML ... does the form as well

sub printBasket {

	# by default all output goes to the caller window
	$TargetDefault = "TARGET=_opener";

	local ($format) = @_[0] || 'DEFAULT';
	local ($editable) = @_[1];

	$editable = 1 if $editable ne '0'; 

	$n = &readBasket() + 1;

	if ($n <= 0) {

	    do printHead ("Nothing Selected"); #UK

	} else {

	    $modify = "Delete unchecked items"; #UK
	    $go = "Reformat list as:"; #UK
	    $eable = "in editable format"; #UK

	    do printHead ("$n items in $WBB{basketName}"); #UK

	    $formats = &formatFormats($CGI{'format'});

	    $ch = '';
	    $ch = 'CHECKED' if $editable; 

	    print <<EOM if $editable;
<FORM ACTION="$SCRIPT/BasketShow" TARGET=_self>
<TABLE CLASS=FORM WIDTH=100%><TR><TD>
<INPUT TYPE=SUBMIT VALUE="$go">
<SELECT NAME="format">
$formats
</SELECT>
<INPUT NAME="editable" TYPE=CHECKBOX $ch>$eable
</TD></TR></TABLE>
</FORM>
EOM

	    print <<EOM if $editable;
<FORM ACTION="$SCRIPT/BasketEdit" TARGET=_self>
EOM

	    do wbSortFields();
	    $PrintingBasket = 1;

	    for ($i=0;$i<=$#BasketID;$i++) {
		$id = $BasketID[$i];
		do wbParseFile("$id.rec",1);
		if ($editable && $FORMAT ne 'TABLE') {
		    $ThisRecordBasket = "<INPUT TYPE=CHECKBOX NAME=r$i CHECKED>";
		} else {
		    $ThisRecordBasket = '';
		}
		$list[$i] = &formatFoundRow($id,$format);
	    }

	    $head = &formatFoundHeader($format);
	    do formatFoundSeparators($format,1);
	    print "<DIV ALIGN=LEFT>" unless $format =~ m/^CSV/;
	    print $t0 . $head;
	    $i=0;
	    foreach $_ (@list) {
	        print "$t1$_$t2";
		$i++;
	    }
	    print $t3;
	    print "</DIV>";

	    $formats = &formatFormats();

	    print <<EOM if $editable;
<TABLE CLASS=FORM WIDTH=100%><TR><TD ALIGN=CENTER>
<INPUT TYPE=SUBMIT VALUE="$modify">
</TABLE>
</FORM>
EOM
	    $PrintingBasket = 0;
	}
	$NOFOOT=1;
}

sub cgiBasketEdit {

	do readBasket();

	for ($i=0;$i<=$#BasketID;$i++) {
	    unless ($CGI{"r$i"} ne '') {
		$BasketNO[$i]=0;
	    }
	}

	do writeBasket();
	do printBasket();
}
   
1;

