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
    
    char *args[] = {"/bin/launchctl", "remove", clabel, NULL};
    
    pid_t pid = fork();
    
    if (pid == 0) {
        // child
        // close file descriptors other than stdio
        for (int i = 3; i < getdtablesize(); i++) {
            close(i);
        }
        
        int status = execv(args[0], args);
        
        // only reached when execve fails
        assert(status == 0);
    }
    
    assert(pid > 0);
    
    int status;
    waitpid(pid, &status, 0);
    
    if (status != 0) {
        retval = paramErr;
    }
    
    return retval;
}
