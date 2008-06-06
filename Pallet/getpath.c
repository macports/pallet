/*
 $Id$

	File:		getpath.c

	Copyright: 	© Copyright 2002 Apple Computer, Inc. All rights reserved.
	
	Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
                        ("Apple") in consideration of your agreement to the following terms, and your
                        use, installation, modification or redistribution of this Apple software
                        constitutes acceptance of these terms.  If you do not agree with these terms,
                        please do not use, install, modify or redistribute this Apple software.
                        
                        In consideration of your agreement to abide by the following terms, and subject
                        to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
                        copyrights in this original Apple software (the "Apple Software"), to use,
                        reproduce, modify and redistribute the Apple Software, with or without
                        modifications, in source and/or binary forms; provided that if you redistribute
                        the Apple Software in its entirety and without modifications, you must retain
                        this notice and the following text and disclaimers in all such redistributions of
                        the Apple Software.  Neither the name, trademarks, service marks or logos of
                        Apple Computer, Inc. may be used to endorse or promote products derived from the
                        Apple Software without specific prior written permission from Apple.  Except as
                        expressly stated in this notice, no other rights or licenses, express or implied,
                        are granted by Apple herein, including but not limited to any patent rights that
                        may be infringed by your derivative works or by other works in which the Apple
                        Software may be incorporated.
                        
                        The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
                        WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
                        WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
                        PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                        COMBINATION WITH YOUR PRODUCTS.
                        
                        IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
                        CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
                        GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
                        ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                        OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
                        (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
                        ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
				
	Change History (most recent first):
                5/1/02		2.0d2		Improved the reliability of determining the path to the
                                                executable during self-repair.
                
                12/19/01	2.0d1		First release of self-repair version.
*/

/* Modified 3/13/07 by Kevin Ballard to avoid using deprecated functions */

#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <sys/param.h>
#include <stdlib.h>
#include <crt_externs.h>
#include <errno.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>

typedef int (*NSGetExecutablePathProcPtr)(char *buf, size_t *bufsize);


static int
NSGetExecutablePathOnTenOneAndEarlierOnly(char *execPath, size_t *execPathSize)
{
    int  	err = 0;
    char 	**cursor;
    char 	*possiblyRelativePath;
    char 	absolutePath[MAXPATHLEN];
    size_t 	absolutePathSize;
    
    assert(execPath != NULL);
    assert(execPathSize != NULL);
    
    cursor = (char **) (*(_NSGetArgv()) + *(_NSGetArgc()));
    
    // There should be a NULL after the argv array.
    // If not, error out.
    
    if (*cursor != 0)
        err = -1;
    
    if (err == 0)
    {
        // Skip past the NULL after the argv array.
        
        cursor += 1;
        
        // Now, skip over the entire kernel-supplied environment, 
        // which is an array of char * terminated by a NULL.
        
        while (*cursor != 0)
        {
            cursor += 1;
        }
        
        // Skip over the NULL terminating the environment.
        
        cursor += 1;

        // Now we have the path that was passed to exec 
        // (not the argv[0] path, but the path that the kernel 
        // actually executed).
        
        possiblyRelativePath = *cursor;

        // Convert the possibly relative path to an absolute 
        // path.  We use realpath for expedience, although 
        // the real implementation of _NSGetExecutablePath
        // uses getcwd and can return a path with symbolic links 
        // etc in it.
        
        if (realpath(possiblyRelativePath, absolutePath) == NULL)
            err = -1;
    }
    
    // Now copy the path out into the client's buffer, returning 
    // an error if the buffer isn't big enough.
    
    if (err == 0)
    {
        absolutePathSize = (strlen(absolutePath) + 1);
        
        if (absolutePathSize <= *execPathSize)
        {
            strcpy(execPath, absolutePath);
        }
        else
        {
            err = -1;
        }
        
        *execPathSize = absolutePathSize;
    }

    return err;
}



int
MyGetExecutablePath(char *execPath, size_t *execPathSize)
{
	NSGetExecutablePathProcPtr funcPtr = NULL;
	if ((funcPtr = (NSGetExecutablePathProcPtr)dlsym(RTLD_DEFAULT, "_NSGetExecutablePath")) == NULL) {
		funcPtr = (NSGetExecutablePathProcPtr)NSGetExecutablePathOnTenOneAndEarlierOnly;
	}
	return funcPtr(execPath, execPathSize);
}

char* getPathToMyself()
{
   size_t path_size = MAXPATHLEN;
   char* path = malloc(path_size);

   if (path && MyGetExecutablePath(path, &path_size) == -1)
   {
      /* Try again with actual size */
      path = realloc(path, path_size + 1);
      if (path && MyGetExecutablePath(path, &path_size) != 0)
      {
	 free(path);
	 path = NULL;
      }
   }
   return path;
}
