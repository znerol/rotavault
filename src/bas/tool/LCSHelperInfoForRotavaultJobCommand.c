/*
 *  LCSHelperInfoForRotavaultJobCommand.c
 *  rotavault
 *
 *  Created by Lorenz Schori on 19.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <unistd.h>
#include "LCSHelperInfoForRotavaultJobCommand.h"
#include "BetterAuthorizationSampleLib.h"
#include "SampleCommon.h"

#if 1
    #include <CoreServices/CoreServices.h>
#else
    #warning Do not ship this way!
    #include <CoreFoundation/CoreFoundation.h>
    #include "/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers/MacErrors.h"
#endif

OSStatus LCSHelperInfoForRotavaultJobCommand(CFStringRef label, CFDictionaryRef *jobdict)
{    
    char clabel[256];
    if (!CFStringGetCString(label, clabel, sizeof(clabel), kCFStringEncodingASCII)) {
        return paramErr;
    }
    
    int pipe_fd[2];
    if (pipe(pipe_fd) == -1) {
        return BASErrnoToOSStatus(errno);
    }
    
    pid_t pid = fork();
    if (pid == -1) {
        return BASErrnoToOSStatus(errno);
    }
    else if (pid == 0) {
        // child

        // redirect stderr (yes, launchctl prints the plist to stderr!)
        dup2(pipe_fd[1], 2);
        
        // close file descriptors other than stdio
        for (int i = 3; i < getdtablesize(); i++) {
            close(i);
        }
        
        char *args[] = {"/bin/launchctl", "list", "-x", clabel, NULL};
        execv(args[0], args);
        asl_log(NULL, NULL, ASL_LEVEL_ERR, "Failed to execute launchctl list: %m");
        
        // only reached when execve fails
        _exit(1);
    }
        
    /* close write end of output */
    close(pipe_fd[1]);
    
    /* read output */
    OSStatus retval = noErr;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    UInt8 buf[1024];
    int len;
    
    for(;;) {
        len = read(pipe_fd[0], buf, sizeof(buf));
        
        if (len > 0) {
            CFDataAppendBytes(data, buf, len);
            continue;
        }
        if (len == 0) {
            break;
        }
        if (errno == EINTR) {
            continue;
        }
        
        retval = readErr;
        break;
    }
    
    /* close read end */
    close(pipe_fd[0]);
    
    /* wait for child and get exit status */
    int status;
    waitpid(pid, &status, 0);
    
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) {
        asl_log(NULL, NULL, ASL_LEVEL_INFO, "Launchctl returned non-zero exit status %d", WEXITSTATUS(status));
        if (retval == noErr) {
            retval = kLCSHelperChildProcessRetunedNonZeroStatus;
        }
    }
    
    if (retval == noErr) {
        /* build result */
        CFPropertyListRef result = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, data, kCFPropertyListImmutable,
                                                                   NULL);
        if (result == NULL) {
            retval = kLCSHelperPropertyListParseError;
        }
        else {
            *jobdict = result;
        }        
    }
    
    CFRelease(data);
    return retval;
}
