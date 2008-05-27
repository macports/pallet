/*
 File: Launcher.c

 Created by David Love on Thu Jul 18 2002.
 Copyright (c) 2002 Cashmere Software, Inc.
 Released to Steven J. Burr on August 21, 2002, under the Gnu General Public License.

 See the header file, Launcher.h for more information on the license.

 */

#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/fcntl.h>
#include <sys/errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <mach-o/dyld.h>
#include <Security/Authorization.h>

#include "Launcher.h"

#define BUFSIZE 4096

static AuthorizationExternalForm extAuth;

enum {
    cmdAuthorized,
    cmdNotAuthorized,
    cmdStatusUndetermined,
    cmdNotOwnedByRoot
};

/*
* Read the incoming authorization byte blob and make sure it's valid
 */
bool readAuthorization(AuthorizationRef *auth)
{
    bool result = FALSE;

    if (read(0, &extAuth, sizeof(extAuth)) == sizeof(extAuth))
    {
        int err;
        err = AuthorizationCreateFromExternalForm(&extAuth, auth);
        result = err == errAuthorizationSuccess;
    }
    fflush(stdout);
    return result;
}

bool authorizedToExecute(AuthorizationRef *auth, const char* cmd)
{
    AuthorizationItem right = { "org.macports.pallet", 0, NULL, 0 };
    AuthorizationRights rights = { 1, &right };
    AuthorizationFlags flags =
        kAuthorizationFlagDefaults | kAuthorizationFlagExtendRights;
    bool result = getuid() == geteuid();

    if(! result)
    {
        result = AuthorizationCopyRights(*auth, &rights,
                                         kAuthorizationEmptyEnvironment,
                                         flags, NULL) == errAuthorizationSuccess;
    }
    return result;
}


/*
 * Determine if the command is one we really want to run as root
 */
int isauthorizedcmd(char * const *cmd, int args)
{
    struct stat st;

    /* Test program name */
    if (!strstr(cmd[1], "/bin/port")		&&
		!strstr(cmd[1], "/bin/portindex")	&&
		!strstr(cmd[1], "/bin/portmirror")	&&
		!strstr(cmd[1], "PalletHelper"))	{
		return cmdNotAuthorized;
    }
    /* Make sure program is owned by root, so it could not have been installed or
		replaced by an ordinary user */
    if (stat(cmd[1], &st) != 0) return cmdStatusUndetermined;
    if (st.st_uid != 0) return cmdNotOwnedByRoot;
    return cmdAuthorized;
}


/*
 * Perform an authorized command
 */
int perform(const char* cmd, char * const *argv)
{
    int status;
    int result = 1;
    int pid;

    pid = fork();
    if (pid == 0) {
		/* If this is the child process, then try to exec cmd */

		setuid(geteuid()); /* set ruid = euid to avoid perl's taint mode */

		if (execvp(cmd, argv) == -1){
			fprintf(stderr, "Execution failed.  errno=%d (%s)\n", errno, strerror(errno));
		}
    }
    else if (pid == -1)
    {
		fprintf(stderr, "fork() failed.  errno=%d (%s)\n", errno, strerror(errno));
    }
    else  {
		fflush(stderr);
		waitpid(pid,&status,0);
		if (WIFEXITED(status))
		{
			result = WEXITSTATUS(status);
		}
		else if (WIFSIGNALED(status))
		{
			result = WTERMSIG(status)+32;
		}
    }
    return result;
}

/*
 *  Copy function used by write_fconf
 */
int mycopy(const char *fromfile, const char *tofile, bool create)
{
    char buffer[BUFSIZE];
    int in_file, out_file;
    int rsize, wsize;
    int wflags = create ? O_WRONLY|O_TRUNC|O_CREAT : O_WRONLY|O_TRUNC;

    /* 	Open fromfile for reading */
    in_file = open(fromfile, O_RDONLY);
    if (in_file == -1) {
		fprintf(stderr, "Failed to open %s for reading, errno=%d (%s)\n",
		  fromfile, errno, strerror(errno));
		return 1;
    }
    /*	Open tofile for writing */
    out_file = open(tofile, wflags, 0644);
    if (out_file == -1) {
		fprintf(stderr,"Failed to open %s for writing, errno=%d (%s)\n",
		  tofile, errno, strerror(errno));
		return 1;
    }
    while (1){
		/*	Read fromfile */
		rsize = read(in_file, buffer, sizeof(buffer));
		if (rsize == 0){	/* EOF */
			break;
		}
		if (rsize == -1){
			fprintf(stderr,"Reading %s failed, errno=%d (%s)\n",
				fromfile, errno, strerror(errno));
			return 1;
		}
		/*	Write tofile  */
		wsize = write(out_file, buffer, (unsigned int)rsize);
		if (wsize == -1){
			fprintf(stderr,"Reading %s failed, errno=%d (%s)\n",
				tofile, errno, strerror(errno));
			return 1;
		}
    }
	close(in_file);
	close(out_file);
	return 0;
}

/*
 *  Back up fink.conf to fink.conf~.
 *  Read in fink.conf.tmp created by FinkConf writeToFile method
 *  Write contents to fink.conf.
 */
int write_fconf(char *basepath)
{
    char fcpath[256];
    char bkpath[256];
    const char *tmpath = "/private/tmp/port.conf.tmp";
    int result;

    strcpy(fcpath, basepath);
    strcpy(bkpath, basepath);
    strcat(fcpath, "/etc/port.conf");
    strcat(bkpath, "/etc/port.conf~");

    /* Back up fink.conf to fink.conf~ */
    result = mycopy(fcpath, bkpath, 1);
    if (result > 0) return result;
    /* Write new fink.conf */
    result = mycopy(tmpath, fcpath, 0);
    return result;
}

/*
 * Self repair code.  We ran ourselves using
 * AuthorizationExecuteWithPrivileges() so we need to make
 * ourselves setuid root to avoid the need for this the next time
 * around.
 * In addition, we set the owner of the Resources directory to root
 * to prevent someone without administrator privileges from replacing
 * Launcher with a malicious version.
 */
int repair_self()
{
    AuthorizationRef auth;
    struct stat st;
    int fd_tool;
    int result = FALSE;
    int resrep = TRUE;
	int chownerr = 0;
	int chmoderr;
    char* path_to_self = getPathToMyself();
#ifndef DEBUGGING
    char path_to_res[BUFSIZE];
    char* end_of_dir;
#endif

 /* Don't change ownership of Resource directory during development;
    it causes clean build to fail. */
#ifndef DEBUGGING
	resrep = FALSE;
    /* Get path to Resource directory */
    strcpy(path_to_res, path_to_self);
    end_of_dir = strrchr(path_to_res, '/');
    if (end_of_dir == NULL) path_to_res[0] = 0;  /* signal failure */
    else *end_of_dir = 0;  /* terminate string at slash */
#endif //DEBUGGING

    if (path_to_self != NULL){
        /* Recover the passed in AuthorizationRef. */
        if (AuthorizationCopyPrivilegedReference(&auth, kAuthorizationFlagDefaults)
            == errAuthorizationSuccess){

            /* Open tool exclusively, so no one can change it while we bless it */
            fd_tool = open(path_to_self, O_NONBLOCK|O_RDONLY|O_EXLOCK, 0);
            if ((fd_tool != -1) && (fstat(fd_tool, &st) == 0)){
                if (st.st_uid != 0)
                    chownerr = fchown(fd_tool, 0, st.st_gid);

                /* Disable group and world writability and make setuid root. */
                chmoderr = fchmod(fd_tool, (st.st_mode & (~(S_IWGRP|S_IWOTH))) | S_ISUID);
                close(fd_tool);
				if (0 == chownerr && 0 == chmoderr){
					result = TRUE;
				}
            }
#ifndef DEBUGGING
			/* Set ownership of Resource directory to root and disable group and world
				writability */
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

/*
 * This is taken almost directly from Apple's example code and will
 * attempt to reset the launcher's setuid permissions if necessary.
 */
int launch_to_repair_self(AuthorizationRef* auth)
{
    int status;
    FILE *commPipe = NULL;
    char *arguments[] = { "--self-repair", NULL };
    int result = EXIT_FAILURE;

    char* path_to_self = getPathToMyself();
    if (path_to_self != NULL){
		fprintf(stderr, "Running self-repair");   /* signal to FinkOutputParser */
		  /* Set our own stdin and stdout to be the communication channel
		  with ourself. */
		  if (AuthorizationExecuteWithPrivileges(*auth, path_to_self, kAuthorizationFlagDefaults,
										   arguments, &commPipe) == errAuthorizationSuccess)
		  {
			  /* Read from stdin and write to commPipe. */
			  fwrite(&extAuth, 1, sizeof(extAuth),commPipe);
			  /* Flush any remaining output. */
			  fflush(commPipe);

			  /* Close the communication pipe to let the child know we are done. */
			  fclose(commPipe);

			  /* Wait for the child of AuthorizationExecuteWithPrivileges to exit. */
			  if (wait(&status) != -1 && WIFEXITED(status))
			  {
				  result = WEXITSTATUS(status);
			  }
		  }
		  free(path_to_self);
    }

/* Exit with the same exit code as the child spawned by
 * AuthorizationExecuteWithPrivileges()
 */
return result;
}


int
main(int argc, char * const *argv)
{
    AuthorizationRef auth;
    int result = 1;

	fprintf(stderr, "Running port...\n");
	/* The caller *must* pass in a valid AuthorizationExternalForm structure on stdin
	 * before they're allowed to go any further.
	 */
    if (! readAuthorization(&auth)){
        fprintf(stderr, "Failed to read authorization from stdin\n");
        exit(1);
    }

    if (argc == 2 && 0 == strcmp(argv[1], "--self-repair")){
        result = repair_self();
    }else if (geteuid() != 0){
		/* If the effective uid isn't root's (0), then we need to reset
		 * the setuid bit on the executable, if possible.
		 */
		result = launch_to_repair_self(&auth);
    }else{
        if (! authorizedToExecute(&auth, argv[1])){
            /* If the caller isn't authorized to run as root, then reset
			 * the effective uid before spawning command
			 */
            seteuid(getuid());
        }
		if (argc == 3 && 0 == strcmp(argv[1], "--kill")){
			/* Kill command being run by Launcher in another process */
			pid_t pid = (pid_t)strtol(argv[2], nil, 10);
			fprintf(stdout, "Killing process %s", argv[2]);
			result = killpg(pid, SIGKILL);
		}else if (argc == 3 && 0 == strcmp(argv[1], "--write_fconf")){
			/* Write changes to fink.conf */
			result = write_fconf(argv[2]);
		}else{
			int pgid;
			pgid = (int)getpgrp();
			//fprintf(stderr, "PGID=%d", pgid);
			switch (isauthorizedcmd(argv, argc)){
				case cmdAuthorized:
					result = perform(argv[1], &argv[1]);
					break;
				case cmdNotAuthorized:
					fprintf(stderr, "WARNING:  An attempt was made to use the Launcher "
							"tool in  Pallet to run an unauthorized command: %s\n", argv[1]);
					break;
				case cmdStatusUndetermined:
					fprintf(stderr, "Error:  Pallet was unable to determine "
							"the owner of %s.\nFor security reasons, Pallet will "
							"not run %s unless it can determine that it is owned by root.\n",
							argv[1], argv[1]);
					break;
				case cmdNotOwnedByRoot:
					fprintf(stderr, "Error:  %s is not owned by root.\nFor security reasons, "
							"Pallet will not run %s unless it is owned by root.\n",
							argv[1], argv[1]);
					break;
			}
		}
    }
    exit(result);
}


