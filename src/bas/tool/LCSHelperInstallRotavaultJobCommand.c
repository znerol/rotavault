/*
 *  LCSHelperInstallRotavaultJobCommand.c
 *  rotavault
 *
 *  Created by Lorenz Schori on 18.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <unistd.h>
#include "LCSHelperInstallRotavaultJobCommand.h"

CFDictionaryRef LCSHelperCreateRotavaultJobDictionary(CFStringRef label, CFStringRef method, CFDateRef rundate,
                                                      CFStringRef source, CFStringRef target,
                                                      CFStringRef sourceChecksum, CFStringRef targetChecksum)
{
    CFMutableDictionaryRef plist = CFDictionaryCreateMutable(kCFAllocatorDefault, 4,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(plist, CFSTR("Label"), label);
    CFDictionaryAddValue(plist, CFSTR("LaunchOnlyOnce"), kCFBooleanTrue);

    CFMutableArrayRef args = CFArrayCreateMutable(kCFAllocatorDefault, 13, &kCFTypeArrayCallBacks);
    CFArrayAppendValue(args, CFSTR("/usr/local/bin/rvcopyd"));
    CFArrayAppendValue(args, CFSTR("-label"));
    CFArrayAppendValue(args, label);
    CFArrayAppendValue(args, CFSTR("-method"));
    CFArrayAppendValue(args, method);
    CFArrayAppendValue(args, CFSTR("-sourcedev"));
    CFArrayAppendValue(args, source);
    CFArrayAppendValue(args, CFSTR("-sourcecheck"));
    CFArrayAppendValue(args, sourceChecksum);
    CFArrayAppendValue(args, CFSTR("-targetdev"));
    CFArrayAppendValue(args, target);
    CFArrayAppendValue(args, CFSTR("-targetcheck"));
    CFArrayAppendValue(args, targetChecksum);
    
    CFDictionaryAddValue(plist, CFSTR("ProgramArguments"), args);
    CFRelease(args);
    
    if (rundate) {
        CFTimeZoneRef systz = CFTimeZoneCopySystem();
        CFGregorianDate gdate = CFAbsoluteTimeGetGregorianDate(CFDateGetAbsoluteTime(rundate), systz);
        CFMutableDictionaryRef caldate = CFDictionaryCreateMutable(kCFAllocatorDefault, 4,
                                                                   &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks);
        
        CFNumberRef value = NULL;
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.minute);
        CFDictionarySetValue(caldate, CFSTR("Minute"), value);
        CFRelease(value);
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.hour);
        CFDictionarySetValue(caldate, CFSTR("Hour"), value);
        CFRelease(value);
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.day);
        CFDictionarySetValue(caldate, CFSTR("Day"), value);
        CFRelease(value);
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.month);
        CFDictionarySetValue(caldate, CFSTR("Month"), value);
        CFRelease(value);        

        CFDictionaryAddValue(plist, CFSTR("StartCalendarInterval"), caldate);
        
        CFRelease(caldate);
        CFRelease(systz);
    }
    else {
        CFDictionaryAddValue(plist, CFSTR("RunAtLoad"), kCFBooleanTrue);
    }
    
    return plist;
}

OSStatus LCSPropertyListWriteToFD(int fd, CFPropertyListRef plist)
{
    CFDataRef xmlData = CFPropertyListCreateXMLData(kCFAllocatorDefault, plist);
    CFIndex blength = CFDataGetLength(xmlData);
    UInt8 *data = malloc(blength);
    CFDataGetBytes(xmlData, CFRangeMake(0, blength), data);
    write(fd, data, blength);
    free(data);
    CFRelease(xmlData);
    return noErr;
}

OSStatus LCSHelperInstallRotavaultLaunchdJob(CFDictionaryRef job)
{
    const char template[] = "/tmp/launchctl-XXXXXXXX";
    char *path = malloc(sizeof(template));
    memcpy(path, template, sizeof(template));
    int fd = mkstemp(path);
    
    LCSPropertyListWriteToFD(fd, job);
    
    char *args[] = {args[0], "load", path, NULL};
    
    pid_t pid = fork();
    
    if (pid == 0) {
        // child
        // close file descriptors other than stdio
        for (int i = 3; i < getdtablesize(); i++) {
            close(i);
        }
        
        int status = execv("/bin/launchctl", args);
        
        // only reached when execve fails
        assert(status == 0);
    }
    
    assert(pid > 0);
    int status;
    waitpid(pid, &status, 0);
    
    close(fd);
    unlink(path);
    return noErr;
}

OSStatus LCSHelperInstallRotavaultJobCommand(CFStringRef label, CFStringRef method, CFDateRef rundate, 
                                             CFStringRef source, CFStringRef target, CFStringRef sourceChecksum,
                                             CFStringRef targetChecksum)
{
    CFDictionaryRef job = LCSHelperCreateRotavaultJobDictionary(label, method, rundate, source, target, sourceChecksum, 
                                                                targetChecksum);
    LCSHelperInstallRotavaultLaunchdJob(job);
    CFRelease(job);
    return noErr;
}
