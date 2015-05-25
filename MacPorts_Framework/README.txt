MacPorts.Framework (Beta) RELEASE NOTES

09/03/2008

MacPorts.Framework 1.0.0

MacPorts url : http://www.macports.org/

MacPorts.Framework is an Objective-C Framework wrapper around the MacPorts Tcl API.


SYSTEM REQUIREMENTS
MacPorts.Framework requires Mac OS X 10.4.11 (or later versions of Mac OS X) to run without
issues. It runs on both ppc and Intel archs since it is compiled as a
universal 32-bit binary.


INSTALLATION
MacPorts.Framework is currently distributed as a port named MacPorts_Framework.
If you have MacPorts installed, you can install by entering (without the quotes)
"port install MacPorts_Framework" or "sudo port install MacPorts_Framework" (if
your MacPorts installation requires permissions) into the command line (Terminal.app).

The installed MacPorts.Framework is located in /Library/Frameworks/.

Alternatively, you can download the source code using svn and build it
with Xcode 3.0 or later.
"svn co https://svn.macports.org/repository/macports/contrib/MacPorts_Framework"

Documentation for the Framework classes can also be obtained with svn:
"svn co https://svn.macports.org/repository/macports/branches/gsoc08-framework/MacPorts_Framework_Documentation" or you can download a .zip version from
https://svn.macports.org/repository/macports/branches/gsoc08-framework/MacPorts_Framework_Documentation/HTML.zip 


USAGE NOTES
The main classes for port manipulation are MPMacPorts and MPPort classes.
MPInterpreter is used internally by those and other classes and is not intended
for use by Framework users. In particular, MPInterpreter is not inherently
thread safe.

Port Activity Notifications
During port operations, MacPorts.Framework sends various types of 
NSNotifications. See MPNotifications' documentation for more info. on that.

Framework users (especially those using the framework for GUI applications) are
encouraged to execute port manipulation operations in a separate worker thread.
This way, your GUI will still be responsive whilst a port operation takes
time to perform its tasks. It is, however, not advisable to run port operations
concurrently. Since most ports have dependencies, unlikely results might
occur if you installed port "foo" and at the same time attempted to uninstall
port "bar".

The source code contains a Test Bundle project and various other classes
that demonstrate usage of the Framework.


KNOWN ISSUES
The framework is still in its beta stage and is distributed under the
BSD License http://opensource.org/licenses/bsd-license.php .

CONTACT
armahg@macports.org







