//
//  LCSTestRamdisk.m
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestRamdisk.h"
#import "LCSInitMacros.h"


@implementation LCSTestRamdisk
@synthesize devnode;
@synthesize mountpoint;

-(id)initWithBlocks:(int)blocks
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    /*
     * Create a ramdisk for our temporary files. Give size in 512-byte sectors (524288 := 256Mib)
     */
    NSPipe *mkrdout = [NSPipe pipe];
    NSTask *mkrd = [[[NSTask alloc] init] autorelease];
    [mkrd setLaunchPath:@"/usr/bin/hdiutil"];
    [mkrd setArguments:[NSArray arrayWithObjects:@"attach", @"-nomount",
                        [NSString stringWithFormat:@"ram://%d", blocks], nil]];
    [mkrd setStandardOutput:mkrdout];
    
    [mkrd launch];
    [mkrd waitUntilExit];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([mkrd terminationStatus] == 0);
    devnode = [[[NSString alloc] initWithData:[[mkrdout fileHandleForReading] readDataToEndOfFile]
                                               encoding:NSUTF8StringEncoding] autorelease];
    devnode = [[devnode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([devnode hasPrefix:@"/dev/disk"]);
    
    /* create filesystem */
    NSString *name = [NSString stringWithFormat:@"test-ramdisk-%0X", random()];
    NSTask *mkfs = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil"
                                            arguments:[NSArray arrayWithObjects:@"erasevolume", @"HFS+", name, devnode, nil]];
    [mkfs waitUntilExit];
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([mkfs terminationStatus] == 0);
    mountpoint = [[NSString stringWithFormat:@"/Volumes/%@", name] retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(mountpoint);
    
    /* Check mountpoint */
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    BOOL isDirectory = NO;
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([fm fileExistsAtPath:mountpoint isDirectory:&isDirectory]);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(isDirectory);
    LCSINIT_RELEASE_AND_RETURN_IF_NIL([fm isWritableFileAtPath:mountpoint]);
    
    return self;
}

- (void) remove
{
    NSTask *rmrd = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:[NSArray arrayWithObjects:@"eject", devnode, nil]];
    [rmrd waitUntilExit];
}

- (void) dealloc
{
    [devnode release];
    [mountpoint release];
    [super dealloc];
}
@end
