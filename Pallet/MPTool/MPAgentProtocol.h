//
//  MPAgent.h
//  DarwinPorts
//
/*
 Copyright (c) 2003 Apple Computer, Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of Apple Computer, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

// mach port names */
#define MPAgentMessagePort @"org.macports.Pallet.Agent"
#define MPAppMessagePort @"org.macports.Pallet.Application"

// port keys 
#define MPNameKey				@"name"
#define MPVersionKey			@"version"
#define MPPortURLKey			@"porturl"
#define MPCategoriesKey			@"categories"
#define MPDependsKey			@"depends_"
#define MPMaintainersKey		@"maintainers"
#define MPPlatformsKey			@"platforms"
#define MPPortDirKey			@"portdir"
#define MPDescriptionKey		@"description"
#define MPLongDescriptionKey	@"long_description"

// targets 
#define MPBuildTarget			@"build"
#define MPCleanTarget			@"clean"
#define MPChecksumTarget		@"checksum"
#define MPConfigureTarget		@"configure"
#define MPExtractTarget			@"extract"
#define MPFetchTarget			@"fetch"
#define MPInstallTarget			@"install"
#define MPPackageTarget			@"package"
#define MPPatchTarget			@"patch"
#define MPUninstallTarget		@"uninstall"

@protocol MPAgentProtocol

- (bycopy NSData *) portsData;
- (oneway void) executeTarget: (in bycopy NSString *)target forPortName: (in bycopy NSString *)portName;

@end


@protocol MPDelegateProtocol

- (oneway void) displayMessage: (in bycopy NSString *)message withPriority: (in bycopy NSString *)priority forPortName: (in bycopy NSString *)portName;
- (BOOL) askMessage: (in bycopy NSString *)message needsResponse: (in bycopy BOOL)wantsResponse forPortName: (in bycopy NSString *)portName;

- (BOOL) shouldPerformTarget: (in bycopy NSString *)target forPortName: (in bycopy NSString *)portName;
- (oneway void) willPerformTarget: (in bycopy NSString *)target forPortName: (in bycopy NSString *)portName;
- (oneway void) didPerformTarget: (in bycopy NSString *)target forPortName: (in bycopy NSString *)portName withResult: (in bycopy NSString *)result;

@end

