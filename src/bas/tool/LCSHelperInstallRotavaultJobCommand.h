/*
 *  LCSHelperInstallRotavaultJobCommand.h
 *  rotavault
 *
 *  Created by Lorenz Schori on 18.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <CoreFoundation/CoreFoundation.h>

OSStatus LCSPropertyListWriteToFD(int fd, CFPropertyListRef plist);

OSStatus LCSHelperInstallRotavaultJobCommand(CFStringRef label, CFStringRef method, CFDateRef rundate, 
                                             CFStringRef source, CFStringRef target, CFStringRef sourceChecksum,
                                             CFStringRef targetChecksum);
