/*
 *  LCSHelperRemoveRotavaultJobCommand.c
 *  rotavault
 *
 *  Created by Lorenz Schori on 20.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <unistd.h>
#include "LCSHelperRemoveRotavaultJobCommand.h"
#include "BetterAuthorizationSampleLib.h"
#include "SampleCommon.h"

#if 1
    #include <CoreServices/CoreServices.h>
#else
    #warning Do not ship this way!
    #include <CoreFoundation/CoreFoundation.h>
    #include "/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers/MacErrors.h"
#endif

OSStatus LCSHelperRemoveRotavaultJobCommand(CFStringRef label)
{
    OSStatus retval = noErr;
    
    char clabel[256];
    if (!CFStringGetCString(label, clabel, sizeof(clabel), kCFStringEncodingASCII)) {
        return paramErr;
    }
    
    pid_t pid = fork();
    if (pid == -1) {
        return BASErrnoToOSStatus(errno);
    }    
    else if (pid == 0) {
        /* close file descriptors other than stdio in child process */
        for (int i = 3; i < getdtablesize(); i++) {
            close(i);
        }
        
        /* execute launchctl */
        char *args[] = {"/bin/launchctl", "remove", clabel, NULL};
        execv(args[0], args);
        asl_log(NULL, NULL, ASL_LEVEL_ERR, "Failed to execute launchctl unload: %m");
        
        /* only reached when execve fails */
        _exit(1);
    }
    
    int status;
    waitpid(pid, &status, 0);
    
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        asl_log(NULL, NULL, ASL_LEVEL_INFO, "Launchctl returned non-zero exit status %d", WEXITSTATUS(status));
        retval = kLCSHelperChildProcessRetunedNonZeroStatus;
    }
    
    return retval;
}
