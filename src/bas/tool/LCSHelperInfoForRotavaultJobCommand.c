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
#include "LCSDictionaryCreateFromLaunchdJobWithLabel.h"
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
    CFPropertyListRef result = LCSDictionaryCreateFromLaunchdJobWithLabel(label);
    
    if (result) {
        *jobdict = result;
        return noErr;
    }
    else {
        return kLCSHelperLaunchdJobNotFound;
    }
}
