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
#if 1
    #include <CoreServices/CoreServices.h>
#else
    #warning Do not ship this way!
    #include <CoreFoundation/CoreFoundation.h>
    #include "/System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers/MacErrors.h"
#endif

OSStatus LCSHelperInfoForRotavaultJobCommand(CFStringRef label, CFDictionaryRef *jobdict)
{
    OSStatus retval = noErr;
    
    char clabel[256];
    if (!CFStringGetCString(label, clabel, sizeof(clabel), kCFStringEncodingASCII)) {
        return paramErr;
    }
    
    char *args[] = {"/bin/launchctl", "list", "-x", clabel, NULL};
    
    int pipe_fd[2];
    assert(pipe(pipe_fd) == 0);
    pid_t pid = fork();
    
    if (pid == 0) {
        // child

        // redirect stderr (yes, launchctl prints the plist to stderr!)
        dup2(pipe_fd[1], 2);
        
        // close file descriptors other than stdio
        for (int i = 3; i < getdtablesize(); i++) {
            if (i == pipe_fd[1]) {
                continue;
            }
        }
        
        int status = execv(args[0], args);
        
        // only reached when execve fails
        assert(status == 0);
    }
    
    assert(pid > 0);
    
    /* close write end of output */
    close(pipe_fd[1]);
    
    /* read output */
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
    
    /* build result */
    if (status == 0) {
        CFPropertyListRef result = CFPropertyListCreateFromXMLData(kCFAllocatorDefault, data,
                                                                   kCFPropertyListImmutable, NULL);
        if (result == NULL) {
            /* FIXME: handle error */
        }
        else {
            *jobdict = result;
        }
    }
    else {
        retval = paramErr;
    }
    
    CFRelease(data);
    return retval;
}
