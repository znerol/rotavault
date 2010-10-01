//
//  LCSDiskUtilOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperationTest.h"
#import "LCSDiskUtilOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSPlistTaskOperation.h"
#import "LCSTestdir.h"


@implementation LCSDiskUtilOperationTest
-(void)setUp
{
    error = nil;
    result = nil;
}

-(void)tearDown
{
    [error release];
    error = nil;
    [result release];
    result = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    if (error == inError) {
        return;
    }
    [error release];
    error = [inError retain];
}

- (void) testListDisks
{
    LCSListDisksOperation *op = [[LCSListDisksOperation alloc] init];
    [op setDelegate:self];
    op.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"result"];

    [op start];
    STAssertNil(error, @"%@", @"LCSListDiskOperation should not cause any errors");
    STAssertNotNil(result, @"%@", @"LCSListDiskOperation must return a result");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"%@", @"Result of LCSListDiskOperation must be an array");
    STAssertTrue([result count] > 0, @"%@", @"LCSListDiskOperation must report at least one entry (startup disk)");

    [op release];
}

-(void) testInfoForDisk
{
    LCSInformationForDiskOperation *op = [[LCSInformationForDiskOperation alloc] init];
    [op setDelegate:self];
    op.device = [LCSSimpleOperationInputParameter parameterWithValue:@"/dev/disk0"];
    op.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"result"];

    [op start];
    STAssertNil(error, @"%@", @"LCSInformationForDiskOperation should not cause any errors for the startup disk");
    STAssertNotNil(result, @"%@", @"LCSInformationForDiskOperation must return a result for the startup disk");
    STAssertTrue([result isKindOfClass:[NSDictionary class]], @"%@", @"Result of LCSInformationForDiskOperation must "
                 @"be a dictionary");
    STAssertTrue([result count] > 0, @"%@", @"Resulting dictionary may not be empty");

    [op release];
}

-(void) testUnmountMountDiskImage
{
    LCSTestdir *testdir = [[LCSTestdir alloc] init];

    /* create image */
    NSString *dmgpath = [[testdir path] stringByAppendingPathComponent:@"test.dmg"];
    NSArray *createargs = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", dmgpath, @"-plist", @"-layout",
                            @"NONE", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *createop = [[LCSPlistTaskOperation alloc] init];
    createop.delegate = self;
    createop.launchPath = [LCSSimpleOperationInputParameter parameterWithValue:@"/usr/bin/hdiutil"];
    createop.arguments = [LCSSimpleOperationInputParameter parameterWithValue:createargs];
    createop.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"result"];
    [createop start];

    STAssertNotNil(result, @"%@", @"return value of hdiutil must not be nil");
    NSString *dev = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(dev, @"%@", @"source device must not be nil");
    [result release];
    result = nil;
    [error release];
    error = nil;

    /* test unmount operation */
    LCSUnmountOperation *unmountop = [[LCSUnmountOperation alloc] init];
    unmountop.delegate = self;
    unmountop.device = [LCSSimpleOperationInputParameter parameterWithValue:dev];
    [unmountop start];

    STAssertNil(error, @"%@", @"No error expected at this time");

    /* test mount operation */
    LCSMountOperation *mountop = [[LCSMountOperation alloc] init];
    mountop.delegate = self;
    mountop.device = [LCSSimpleOperationInputParameter parameterWithValue:dev];
    [mountop start];

    STAssertNil(error, @"%@", @"No error expected at this time");

    /* eject disk */
    NSArray *ejectargs = [NSArray arrayWithObjects:@"eject", dev, nil];
    NSTask *ejecttask = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/diskutil" arguments:ejectargs];
    [ejecttask waitUntilExit];

    /* release objects */
    [dev release];
    [createop release];
    [unmountop release];
    [mountop release];

    /* cleanup temporary directory */
    [testdir remove];
    [testdir release];
}

@end
