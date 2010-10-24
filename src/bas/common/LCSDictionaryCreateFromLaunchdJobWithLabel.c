/*
 *  LCSDictionaryCreateFromLaunchdJobWithLabel.c
 *  rotavault
 *
 *  Created by Lorenz Schori on 24.10.10.
 *  Copyright 2010 znerol.ch. All rights reserved.
 *
 */

#include "LCSDictionaryCreateFromLaunchdJobWithLabel.h"

/*
 * Derived from http://www.opensource.apple.com/source/launchd/launchd-258.25/launchd/src/launchctl.c
 */

CFDictionaryRef LCSDictionaryCreateFromLaunchData(launch_data_t obj);
void LCSLaunchdObjectToPropertyList(launch_data_t obj, const char *key, void *container);

CFDictionaryRef LCSDictionaryCreateFromLaunchData(launch_data_t obj)
{
    CFDictionaryRef result;
    size_t c = launch_data_dict_get_count(obj);
    result = CFDictionaryCreateMutable(kCFAllocatorDefault, c, &kCFTypeDictionaryKeyCallBacks,
                                       &kCFTypeDictionaryValueCallBacks);
    launch_data_dict_iterate(obj, LCSLaunchdObjectToPropertyList, (void*)result);
    return result;
}

void LCSLaunchdObjectToPropertyList(launch_data_t obj, const char *key, void *container)
{
    CFPropertyListRef value = NULL;
	size_t i, c;
    union {
        const char* strval;
        long long   intval;
        double      realval;
        int         boolval;
        
    } buf;
    
	switch (launch_data_get_type(obj)) {
        case LAUNCH_DATA_STRING:
            buf.strval = launch_data_get_string(obj);
            value = CFStringCreateWithCString(kCFAllocatorDefault, buf.strval, kCFStringEncodingASCII);
            break;
        case LAUNCH_DATA_INTEGER:
            buf.intval = launch_data_get_integer(obj);
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongLongType, &buf.intval);
            break;
        case LAUNCH_DATA_REAL:
            buf.realval = launch_data_get_real(obj);
            value = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &buf.realval);
            break;
        case LAUNCH_DATA_BOOL:
            value = (launch_data_get_bool(obj) ? kCFBooleanTrue : kCFBooleanFalse);
            break;
        case LAUNCH_DATA_ARRAY:
            c = launch_data_array_get_count(obj);
            value = CFArrayCreateMutable(kCFAllocatorDefault, c, &kCFTypeArrayCallBacks);
            for (i = 0; i < c; i++) {
                LCSLaunchdObjectToPropertyList(launch_data_array_get_index(obj, i), NULL, (void*)value);
            }
            break;
        case LAUNCH_DATA_DICTIONARY:
            value = LCSDictionaryCreateFromLaunchData(obj);
            break;
        default:
            /* do nothing if we don't know how to handle the type */
            break;
	}
    
    if (value) {
        if (CFGetTypeID(container) == CFDictionaryGetTypeID() && key != NULL) {
            CFStringRef keystring = CFStringCreateWithCString(kCFAllocatorDefault, key, kCFStringEncodingASCII);
            CFDictionarySetValue(container, keystring, value);
            CFRelease(keystring);
        }
        else if (CFGetTypeID(container) == CFArrayGetTypeID()) {
            CFArrayAppendValue(container, value);
        }
        CFRelease(value);
    }
}

CFPropertyListRef LCSDictionaryCreateFromLaunchdJobWithLabel(CFStringRef label)
{
    CFPropertyListRef retval = NULL;
    char clabel[256];
    
    launch_data_t resp, msg;
    msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
    if (!CFStringGetCString(label, clabel, sizeof(clabel), kCFStringEncodingASCII)) {
        launch_data_free(msg);
        return NULL;
    }
    
    launch_data_dict_insert(msg, launch_data_new_string(clabel), LAUNCH_KEY_GETJOB);
    
    resp = launch_msg(msg);
    launch_data_free(msg);
    
    if (resp == NULL) {
        return NULL;
    }
    
    if (launch_data_get_type(resp) == LAUNCH_DATA_DICTIONARY) {
        retval = LCSDictionaryCreateFromLaunchData(resp);
    }
    
    launch_data_free(resp);
    
    return retval;
}


