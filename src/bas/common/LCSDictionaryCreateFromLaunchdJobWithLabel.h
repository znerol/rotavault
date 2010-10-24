/*
 *  LCSDictionaryCreateFromLaunchdJobWithLabel.h
 *  rotavault
 *
 *  Created by Lorenz Schori on 24.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include <CoreFoundation/CoreFoundation.h>
#include <launch.h>

CFPropertyListRef LCSDictionaryCreateFromLaunchdJobWithLabel(CFStringRef label);
