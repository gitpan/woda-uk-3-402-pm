#!/usr/local/bin/perl

require "/usr/local/woda/woda-uk.pl" unless defined &main;

#
# Database definition:
#

$WBB{'dbTitle'} = 'Staff of the XYZ corporation';
$WBB{'about'} = 'This database is a demo application for WODA,
demonstrates some features and provides a template for end-user applications. 
';
$WBB{'recordTitle'} = 'Personal data';
$WBB{'language'} = 'uk';
$WBB{'pageBody'} = 'BGCOLOR="#E0E0E0"';
$WBB{'manager'} = 'Ziga Turk';
$WBB{'managerEmail'} = 'ziga.turk@fagg.uni-lj.si';
$WBB{'dataDir'} = '/usr/local/www/htdocs/woda/data/demo';
$WBB{'homeURL'} = '/woda/data/demo';
$WBB{'sort;DEFAULT'} = '"$rec{lastName};$rec{firstName}"';
$WBB{'format;DEFAULT'} = '$rec{homePage} ?
"<A HREF=$rec{homePage}>$rec{firstName} <B>$rec{lastName}</B></A> (<A HREF=mailto:$rec{email}>$rec{email}</A>)"
:
"$rec{firstName} <B>$rec{lastName}</B> (<A HREF=mailto:$rec{email}>$rec{email}</A>)"';
$WBB{'key'} = '"$rec{username}"';

#
# Field definitions:
#

$i=1000;		# counter


$x='firstName';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = 'm/[A-Za-z\-\. ]{1,40}/';
$WBF{$x,'cond'} = '1-40 US letters, dots and dashes!';
$WBF{$x,'help'} = 'Enter the first name followed by any middle initials e.g. <I>John F.</I>';
$WBF{$x,'picture'} = '"<BIG>$_</BIG>"';

$x='lastName';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = 'm/[A-Za-z\-]{1,40}/';
$WBF{$x,'cond'} = '1-40 US letters, dots and dashes!';
$WBF{$x,'help'} = 'Enter last name. If You have two, separate them with a dash e.g. <I>Martin-Smith</I>';
$WBF{$x,'picture'} = '"<BIG>$_</BIG>"';

$x='username';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x,'p'} = 'Username';
$WBF{$x} = 'm/[a-z]{2,8}/';
$WBF{$x,'cond'} = '2-8 small US leters';
$WBF{$x,'typePar'} = 'SIZE=8';
$WBF{$x,'help'} = 'Enter your username.';

$x='picture';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = 'm/gif$|jpg$|^$/';
$WBF{$x,'type'} = 'IMAGE';
$WBF{$x,'help'} = 'Adding an image is optional. But if you have one, upload it!';

$x='resume';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = 'm/pdf$|doc$|^$/';
$WBF{$x,'type'} = 'USERFILE';
$WBF{$x,'help'} = 'Adding a resume in .pdf or .doc format is also optional. Hey, this is a demo!';

$x='about';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = '1;';
$WBF{$x,'type'} = 'TEXTAREA';
$WBF{$x,'typePar'} = 'ROWS=5 COLS=60';
$WBF{$x,'p'} = 'Tell us more about yourself!';


$x='title';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = '1;';
$WBF{$x,'type'} = 'OPTION';
$WBF{$x,'typePar'} = 'RADIO';
$WBF{$x,'options'} = 'Mr.|Mrs.|Ms.|Miss|M.S.|Dr.|Asst.Prof.|Assoc.Prof.|Prof.|Acad.Prof.';


$x='email';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = '1;';
$WBF{$x,'d'} = 'info@fagg.uni-lj.si';
$WBF{$x,'type'} = 'EMAIL';
$WBF{$x,'sticky'} = '1';
$WBF{$x,'help'} = 'Enter your email address.';

$x='topic';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x,'p'} = 'Classify the area of your expertise';
$WBF{$x} = '1;';
$WBF{$x,'type'} = 'OPTION';
$WBF{$x,'typePar'} = 'TREE MULTIPLE CHECKBOX';
$WBF{$x,'options'} = '
mathematics
mathematics:algebra
mathematics:analisys
mathematics:geometry
physics
physics:mechanics
physics:nuclear
physics:nuclear:particle
physics:of materials
geodesy
civil engineering
civil engineering:structural
civil engineering:concrete
civil engineering:metal
civil engineering:metal:steel
civil engineering:metal:aluminum
information technology
information technology:programming
information technology:programming:C
information technology:programming:Perl
information technology:programming:Ada
';

$x='homePage';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = '1;';
$WBF{$x,'type'} = 'URL';
$WBF{$x,'help'} = 'If you have a home page, enter it here.';

$x='break';
$WBF{$x,srt}=$i--;
$WBF{$x,'type'} = 'BREAK';
$WBF{$x} = 'Other data';

$x='relatives';	# ------------------------------ 
$WBF{$x,srt}=$i--;
$WBF{$x} = '1;';
$WBF{$x,'type'} = 'COMPUTE';
$WBF{$x,'picture'} = '"<A HREF=$SCRIPT/search?search=$rec{lastName}>Find your relatives</A>"';

# --------

do main();

