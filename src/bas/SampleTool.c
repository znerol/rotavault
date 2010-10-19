/*
	File:       SampleTool.c

    Contains:   Helper tool side of the example of how to use BetterAuthorizationSampleLib.

    Written by: DTS

    Copyright:  Copyright (c) 2007 Apple Inc. All Rights Reserved.

    Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple, Inc.
                ("Apple") in consideration of your agreement to the following terms, and your
                use, installation, modification or redistribution of this Apple software
                constitutes acceptance of these terms.  If you do not agree with these terms,
                please do not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following terms, and subject
                to these terms, Apple grants you a personal, non-exclusive license, under Apple's
                copyrights in this original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or without
                modifications, in source and/or binary forms; provided that if you redistribute
                the Apple Software in its entirety and without modifications, you must retain
                this notice and the following text and disclaimers in all such redistributions of
                the Apple Software.  Neither the name, trademarks, service marks or logos of
                Apple, Inc. may be used to endorse or promote products derived from the
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

 */
 
#include <netinet/in.h>
#include <stdio.h>
#include <sys/socket.h>
#include <unistd.h>

#include <CoreServices/CoreServices.h>

#include "BetterAuthorizationSampleLib.h"
#include "LCSHelperInstallRotavaultJobCommand.h"

#include "SampleCommon.h"

/**
 * Implements the kLCSHelperInstallRotavaultJobCommand.
 */
static OSStatus JobInstallCommand(AuthorizationRef auth, const void * userData, CFDictionaryRef request,
                                  CFMutableDictionaryRef response, aslclient asl, aslmsg aslMsg)
{	
	OSStatus retval = noErr;
	
	// Pre-conditions
	
	assert(auth != NULL);
    // userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
    // asl may be NULL
    // aslMsg may be NULL
    
    CFStringRef label = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobLabelParameter));
    CFStringRef method = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobMethod));
    CFDateRef rundate = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobRunDateParameter));
    CFStringRef source = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobSourceParameter));
    CFStringRef target = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobTargetParameter));
    CFStringRef sourcecheck = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobSourceChecksumParameter));
    CFStringRef targetcheck = CFDictionaryGetValue(request, CFSTR(kLCSHelperInstallRotavaultJobTargetChecksumParameter));
    
    retval = LCSHelperInstallRotavaultJobCommand(label, method, rundate, source, target, sourcecheck, targetcheck);
    
	return retval;
}

/**
 * Implements the kLCSHelperRemoveRotavaultJobCommand.
 */
static OSStatus JobRemoveCommand(AuthorizationRef auth, const void * userData, CFDictionaryRef request,
                                  CFMutableDictionaryRef response, aslclient asl, aslmsg aslMsg)
{	
	OSStatus retval = noErr;
	
	// Pre-conditions
	
	assert(auth != NULL);
    // userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
    // asl may be NULL
    // aslMsg may be NULL
	
    
	return retval;
}

/**
 * Implements the kLCSHelperInfoForRotavaultJobCommand.
 */
static OSStatus JobInfoCommand(AuthorizationRef auth, const void * userData, CFDictionaryRef request,
                               CFMutableDictionaryRef response, aslclient asl, aslmsg aslMsg)
{	
	OSStatus retval = noErr;
	
	// Pre-conditions
	
	assert(auth != NULL);
    // userData may be NULL
	assert(request != NULL);
	assert(response != NULL);
    // asl may be NULL
    // aslMsg may be NULL
	
    
	return retval;
}

/*
    IMPORTANT
    ---------
    This array must be exactly parallel to the kSampleCommandSet array 
    in "SampleCommon.c".
*/

static const BASCommandProc kLCSHelperCommandProcs[] = {
    JobInstallCommand,
    JobRemoveCommand,
    JobInfoCommand,
    NULL
};

int main(int argc, char **argv)
{
    // Go directly into BetterAuthorizationSampleLib code.
	
    // IMPORTANT
    // BASHelperToolMain doesn't clean up after itself, so once it returns 
    // we must quit.
    
	return BASHelperToolMain(kLCSHelperCommandSet, kLCSHelperCommandProcs);
}
