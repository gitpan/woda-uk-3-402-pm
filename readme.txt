WODA - Web Oriented Database System

STATUS
======
This is released software, but under constant development.

DESCRIPTION
===========
WODA is a Perl program that manages web-oriented, semi-relational, multimedia
databases. It allows them to be maintained, added-to, modified, and queried through
the WWW. One could also call it a RAD (Rapid Application Development) system
for web database applications but it would be a bit of an overstatement. 

WODA works so that the database administrator defines the database by setting up
two Perl hashes %WBB and %WBF and then calls function main from the WODA library.
(example is in file demo.cgi). Based on this definition WODA than displays
all screens and forms needed to use and manage the database.

Administrators are urged to read the documentation at http://itc.fgg.uni-lj.si/woda/

REQUIREMENTS
============
* Perl (4.036 and above).
* Web server software that does CGI (Apache or Xitami are suggested for Windows)

INSTALLATION
============
WODA comes either in .zip or .tar.gz file. 

1) This file should be unpacked (on Windows Windows Commander or Winzip are good tools
   for the job. WARNING: On case sensitive systems, the case of files in the /woda/??/
   directory must be preserved! Use tar.gz on UNIX or unzip -U !

2) Run
	perl install
   This should copy the right files to all the right places.

3) Test it by calling http://your.host.name/cgi-or-whatever/test.cgi and then demo.cgi

COPYRIGHT
=========
WODA is available under the same terms as Perl itself - GNU and Artistic licences apply.
See license.txt

--
Ziga Turk
ziga.turk@fagg.uni-lj.si
