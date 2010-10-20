/*
 *  LCSCreateRotavaultJobDictionary.h
 *  rotavault
 *
 *  Created by Lorenz Schori on 20.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <CoreFoundation/CoreFoundation.h>

CFDictionaryRef LCSRotavaultCreateJobDictionary(CFStringRef label, CFStringRef method, CFDateRef rundate,
                                                         CFStringRef source, CFStringRef target,
                                                         CFStringRef sourceChecksum, CFStringRef targetChecksum);
