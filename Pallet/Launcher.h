/*
 File: Launcher.h

 FinkCommander

 Graphical user interface for Fink, a software package management system
 that automates the downloading, patching, compilation and installation of
 Unix software on Mac OS X.

 This file, Launcher.c and getpath.c are used to build the setuid root Launcher tool which runs 
 fink and apt-get commands, terminates those commands at the request of the user and
 writes changes to fink.conf.

 Created by David Love on Thu Jul 18 2002.
 Copyright (c) 2002 Cashmere Software, Inc.
 Released to Steven J. Burr on August 21, 2002, under the Gnu General Public License.
 
 I've made some changes to David's code.  If you see anything in here that doesn't make sense:
 (a) You can safely assume it's my modification, not the original code.
 (b) Let me know.
 
 This program is free software; you may redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

 Contact the author at sburrious@users.sourceforge.net.

 */

extern char* getPathToMyself();
