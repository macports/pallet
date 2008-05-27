//
//  Launcher.m
//  Pallet
//
//  Created by Randall Hansen Wood on 27/12/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#include <sys/stat.h>

#import "Launcher.h"

extern char* getPathToMyself();

#define BUFSIZE 4096

enum {
    cmdAuthorized,
    cmdNotAuthorized,
    cmdStatusUndetermined,
    cmdNotOwnedByRoot
};

int selfRepair() {
	AuthorizationRef authorization;
    struct stat st;
    int fd_tool;
    int result = FALSE;
    int resrep = TRUE;
	int chownerr = 0;
	int chmoderr;
    char* path_to_self = getPathToMyself();
    char path_to_res[BUFSIZE];
    char* end_of_dir;

#ifndef DEBUGGING
	resrep = FALSE;
    //* Get path to Resource directory *
    strcpy(path_to_res, path_to_self);
    end_of_dir = strrchr(path_to_res, '/');
    if (end_of_dir == NULL) path_to_res[0] = 0;  //* signal failure *
    else *end_of_dir = 0;  //* terminate string at slash *
#endif //DEBUGGING
    if (path_to_self != NULL){
        //* Recover the passed in AuthorizationRef. *
        if (AuthorizationCopyPrivilegedReference(&authorization, kAuthorizationFlagDefaults)
            == errAuthorizationSuccess){
			
            //* Open tool exclusively, so no one can change it while we bless it *
            fd_tool = open(path_to_self, O_NONBLOCK|O_RDONLY|O_EXLOCK, 0);
            if ((fd_tool != -1) && (fstat(fd_tool, &st) == 0)){
                if (st.st_uid != 0)
                    chownerr = fchown(fd_tool, 0, st.st_gid);
				
                //* Disable group and world writability and make setuid root. *
                chmoderr = fchmod(fd_tool, (st.st_mode & (~(S_IWGRP|S_IWOTH))) | S_ISUID);
                close(fd_tool);
				if (0 == chownerr && 0 == chmoderr){
					result = TRUE;
				}
            }
#ifndef DEBUGGING
			//* Set ownership of Resource directory to root and disable group and world
			//	writability *
			if (path_to_res[0] != 0){
				if (stat(path_to_res, &st) == 0){
					chownerr = chown(path_to_res, 0, st.st_gid);
					chmoderr = chmod(path_to_res, st.st_mode & (~(S_IWGRP|S_IWOTH)));
					if (0 == chownerr && 0 == chmoderr){
						resrep = TRUE;
					}
				}
			}
#endif //DEBUGGING
		}else{
			fprintf(stderr, "Authentication as administrator failed.\n");
		}
		free(path_to_self);
    }else{
		fprintf(stderr, "Unable to determine path to setuid tool.\n");
    }
	
    if (result && resrep){
		fprintf(stderr, "Self-repair succeeded\n");
    }else if (result){
		fprintf(stderr, "/n/nWARNING:  Unable to modify Resource directory\n");
    }else{
		fprintf(stderr, "/n/nERROR:  Self-repair failed.  Please be sure you are running Pallet from a directory and disk you are authorized to modify (e.g., not a disk image).\n");
    }
    return ! result;  //will be used as exit code; so return 0 if successful, 1 otherwise	
}

int main(int argc, char * const *argv) {
	AuthorizationRef *authorization;
	AuthorizationExternalForm *externalAuthorization;
	int result = 1;
	
	if (read(0, &externalAuthorization, sizeof(externalAuthorization)) == sizeof(externalAuthorization)) {
		if (AuthorizationCreateFromExternalForm(externalAuthorization, authorization) == errAuthorizationSuccess) {
			if (argc == 2 && [[[[NSProcessInfo processInfo] arguments] objectAtIndex:1] isEqualToString:@"--self-repair"]) {
				result = selfRepair();
			} else if (geteuid() != 0) {
				result = relaunchForSelfRepair(&authorization);
			} else {
				if (!authorizedToExecute(&authorization, [[[NSProcessInfo processInfo] arguments] objectAtIndex:1])) {
					seteuid(geteuid());
				}
				if (argc == 3 && [[[[NSProcessInfo processInfo] arguments] objectAtIndex:1] isEqualToString:@"--kill"]) {
					pid_t pid = (pid_t)[[[[NSProcessInfo processInfo] arguments] objectAtIndex:2] intValue];
					NSLog(@"Killing process %s", argv[2]);
					result = killLauncher(pid, SIGKILL);
				} else if (argc == 3 && [[[[NSProcessInfo processInfo] arguments] objectAtIndex:1] isEqualToString:@"--write-port-conf"]) {
					result = writePortConf([[[NSProcessInfo processInfo] arguments] objectAtIndex:2]);
				} else {
					int pgid;
					pgid = (int)getpgrp();
					NSLog(@"PGID=%d", pgid);
					switch (isAuthorized([[NSProcessInfo processInfo] arguments])) {
						case cmdAuthorized:
							result = perform([[NSProcessInfo processInfo] arguments]);
							break;
						case cmdNotAuthorized:
							NSLog(@"WARNING: An attempt was made to use the Launcher tool in Pallet to run an unauthorized command: %s\n", [[[NSProcessInfo processInfo] arguments] objectAtIndex:1]);
							break;
						case cmdStatusUndetermined:
							NSLog(@"ERROR:  Pallet was unable to determine the owner of %s.\nFor security reasons, Pallet will not run %s unless it can determine that it is owned by root.\n", [[[NSProcessInfo processInfo] arguments] objectAtIndex:1], [[[NSProcessInfo processInfo] arguments] objectAtIndex:1]);
							break;
						case cmdNotOwnedByRoot:
							NSLog(@"ERROR:  %s is not owned by root.\nFor security reasons, Pallet will not run %s unless it is owned by root.\n", [[[NSProcessInfo processInfo] arguments] objectAtIndex:1], [[[NSProcessInfo processInfo] arguments] objectAtIndex:1]);
							break;
					}
				}
			}
			exit(result);
		}
	}

	NSLog(@"Failed to read authorization from stdin\n");
	exit(1);
}