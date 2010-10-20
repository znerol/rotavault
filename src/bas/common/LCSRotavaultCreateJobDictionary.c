/*
 *  LCSCreateRotavaultJobDictionary.c
 *  rotavault
 *
 *  Created by Lorenz Schori on 20.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include "LCSRotavaultCreateJobDictionary.h"

CFDictionaryRef LCSRotavaultCreateJobDictionary(CFStringRef label, CFStringRef method, CFDateRef rundate,
                                                         CFStringRef source, CFStringRef target,
                                                         CFStringRef sourceChecksum, CFStringRef targetChecksum)
{
    CFMutableDictionaryRef plist = CFDictionaryCreateMutable(kCFAllocatorDefault, 4,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    if (plist == NULL) {
        return NULL;
    }
    
    CFDictionaryAddValue(plist, CFSTR("Label"), label);
    CFDictionaryAddValue(plist, CFSTR("LaunchOnlyOnce"), kCFBooleanTrue);
    
    CFMutableArrayRef args = CFArrayCreateMutable(kCFAllocatorDefault, 13, &kCFTypeArrayCallBacks);
    if (args == NULL) {
        CFRelease(plist);
        return NULL;
    }
    
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
        if (systz == NULL) {
            CFRelease(plist);
            return NULL;
        }
        
        CFGregorianDate gdate = CFAbsoluteTimeGetGregorianDate(CFDateGetAbsoluteTime(rundate), systz);
        CFMutableDictionaryRef caldate = CFDictionaryCreateMutable(kCFAllocatorDefault, 4,
                                                                   &kCFTypeDictionaryKeyCallBacks,
                                                                   &kCFTypeDictionaryValueCallBacks);
        if (caldate == NULL) {
            CFRelease(plist);
            return NULL;
        }
        
        CFNumberRef value = NULL;
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.minute);
        if (value == NULL) {
            CFRelease(caldate);
            CFRelease(plist);
            return NULL;
        }
        CFDictionarySetValue(caldate, CFSTR("Minute"), value);
        CFRelease(value);
        
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.hour);
        if (value == NULL) {
            CFRelease(caldate);
            CFRelease(plist);
            return NULL;
        }
        CFDictionarySetValue(caldate, CFSTR("Hour"), value);
        CFRelease(value);
        
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.day);
        if (value == NULL) {
            CFRelease(caldate);
            CFRelease(plist);
            return NULL;
        }
        CFDictionarySetValue(caldate, CFSTR("Day"), value);
        CFRelease(value);
        
        value = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &gdate.month);
        if (value == NULL) {
            CFRelease(caldate);
            CFRelease(plist);
            return NULL;
        }
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
