//
//  LCSDiskArbitration.m
//  rotavault
//
//  Created by Lorenz Schori on 03.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskArbitration.h"
#import "LCSInitMacros.h"

NSString* LCSDiskAppearedNotification = @"LCSDiskAppeared";
NSString* LCSDiskDescriptionChangedNotification = @"LCSDiskDescriptionChanged";
NSString* LCSDiskDisappearedNotification = @"LCSDiskDisappeared";

NSString* LCSDiskChangedKeysKey = @"LCSDiskChangedKeys";

@interface LCSDiskArbitration (Internal)
- (void)addDisk:(NSString*)disk;
- (void)removeDisk:(NSString*)disk;
@end


void LCSDiskArbitrationAppearedCallback(DADiskRef disk, void * context)
{
    NSString *bsdname = [NSString stringWithUTF8String:DADiskGetBSDName(disk)];
    
    LCSDiskArbitration* da = (LCSDiskArbitration*)context;
    [da addDisk:bsdname];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LCSDiskAppearedNotification object:bsdname];
}

void LCSDiskArbitrationDisappearedCallback(DADiskRef disk, void * context)
{
    NSString *bsdname = [NSString stringWithUTF8String:DADiskGetBSDName(disk)];
    
    LCSDiskArbitration* da = (LCSDiskArbitration*)context;
    [da removeDisk:bsdname];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LCSDiskDisappearedNotification object:bsdname];
}

void LCSDiskArbitrationDescriptionChangedCallback(DADiskRef disk, CFArrayRef keys, void * context)
{
    NSString *bsdname = [NSString stringWithUTF8String:DADiskGetBSDName(disk)];
    [[NSNotificationCenter defaultCenter] postNotificationName:LCSDiskDescriptionChangedNotification object:bsdname];
}

LCSDiskArbitration* LCSDiskArbitrationSharedInstance = nil;

@implementation LCSDiskArbitration
+ (LCSDiskArbitration*) sharedInstance
{
    if (!LCSDiskArbitrationSharedInstance) {
        LCSDiskArbitrationSharedInstance = [[LCSDiskArbitration alloc] init];
        LCSDiskArbitrationSharedInstance.runloop = [NSRunLoop currentRunLoop];
    }
    
    return LCSDiskArbitrationSharedInstance;
}

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    session = DASessionCreate(kCFAllocatorDefault);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(session);
    
    DARegisterDiskAppearedCallback(session, NULL, LCSDiskArbitrationAppearedCallback, self);
    DARegisterDiskDisappearedCallback(session, NULL, LCSDiskArbitrationDisappearedCallback, self);
    DARegisterDiskDescriptionChangedCallback(session, NULL, NULL, LCSDiskArbitrationDescriptionChangedCallback, self);
    
    return self;
}

- (void)dealloc
{
    if (session) {
        self.runloop = nil;
        
        DAUnregisterCallback(session, LCSDiskArbitrationAppearedCallback, self);
        DAUnregisterCallback(session, LCSDiskArbitrationDisappearedCallback, self);
        DAUnregisterCallback(session, LCSDiskArbitrationDescriptionChangedCallback, self);
        CFRelease(session);
    }
    
    [super dealloc];
}

- (void)setRunloop:(NSRunLoop *)newRunloop
{
    if (newRunloop == runloop) {
        
    }
    
    if (runloop) {
        DASessionUnscheduleFromRunLoop(session, [runloop getCFRunLoop], kCFRunLoopDefaultMode);
    }
    
    runloop = newRunloop;
    
    if (runloop) {
        DASessionScheduleWithRunLoop(session, [runloop getCFRunLoop], kCFRunLoopDefaultMode);
    }
}

- (NSRunLoop*)runloop
{
    return runloop;
}

- (void)addDisk:(NSString*)disk
{
    NSLog(@"DEBUG: add disk %@", disk);
    [disks addObject:disk];
}

- (void)removeDisk:(NSString *)disk
{
    NSLog(@"DEBUG: remove disk %@", disk);
    [disks removeObject:disk];
}

@synthesize disks;
@end
