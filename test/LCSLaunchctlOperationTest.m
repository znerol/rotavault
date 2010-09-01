//
//  LCSLaunchctlOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlOperationTest.h"
#import "LCSLaunchctlOperation.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSTestdir.h"


@implementation LCSLaunchctlOperationTest

-(void)setUp
{
    error = nil;
}

-(void)tearDown
{
    [error release];
    error = nil;
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

-(void)testLaunchctlInfoOperation
{
    srandom(time(NULL));

    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];

    NSArray *submitArgs = [NSArray arrayWithObjects:@"submit", @"-l", label, @"--", @"/bin/sleep", @"10", nil];
    NSTask *submitTestSleepCommand = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:submitArgs];
    [submitTestSleepCommand waitUntilExit];
    STAssertEquals([submitTestSleepCommand terminationStatus], 0,
                   @"Failed to submit testjob with label %@ to launchctl", label);

    NSDictionary* result = nil;
    LCSLaunchctlInfoOperation *op = [[LCSLaunchctlInfoOperation alloc] init];
    op.label = [[LCSSimpleOperationInputParameter alloc] initWithValue:label];
    op.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    op.delegate = self;
    [op start];

    STAssertNil(error, @"%@", @"No error expected here");
    STAssertNotNil(result, @"%@", @"Result may not be nil after the launchctl info operation");
    STAssertTrue([result isKindOfClass:[NSDictionary class]], @"%@", @"Result must be a dictionary");

    NSArray *removeArgs = [NSArray arrayWithObjects:@"remove", label, nil];
    NSTask *removeTestSleepCommand = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:removeArgs];
    [removeTestSleepCommand waitUntilExit];
    STAssertEquals([removeTestSleepCommand terminationStatus], 0,
                   @"Failed to remove testjob with label %@ to launchctl", label);
    
}

-(void)testLaunchctlInfoOperationNoJob
{
    srandom(time(NULL));
    
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
        
    NSDictionary* result = nil;
    LCSLaunchctlInfoOperation *op = [[LCSLaunchctlInfoOperation alloc] init];
    op.label = [[LCSSimpleOperationInputParameter alloc] initWithValue:label];
    op.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    op.delegate = self;
    [op start];
    
    STAssertNil(result, @"%@", @"Result may not be nil after the launchctl info operation");
    STAssertNotNil(error, @"%@", @"Operation must report an error launchctl job was not found");    
}

-(void)testLaunchctlListOperation
{
    srandom(time(NULL));
    
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    NSArray *submitArgs = [NSArray arrayWithObjects:@"submit", @"-l", label, @"--", @"/bin/sleep", @"10", nil];
    NSTask *submitTestSleepCommand = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:submitArgs];
    [submitTestSleepCommand waitUntilExit];
    STAssertEquals([submitTestSleepCommand terminationStatus], 0,
                   @"Failed to submit testjob with label %@ to launchctl", label);
    
    NSArray* result = nil;
    LCSLaunchctlListOperation *op = [[LCSLaunchctlListOperation alloc] init];
    op.result = [[LCSSimpleOperationOutputParameter alloc] initWithReturnValue:&result];
    op.delegate = self;
    [op start];

    STAssertNil(error, @"%@", @"No error expected here");
    STAssertNotNil(result, @"%@", @"Result may not be nil after the launchctl list operation");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"%@", @"Result must be an array");

    NSArray *found = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"Label = %@", label]];
    STAssertEquals([found count], (NSUInteger)1, @"Submitted job with label %@ must be in the result list", label);

    NSArray *removeArgs = [NSArray arrayWithObjects:@"remove", label, nil];
    NSTask *removeTestSleepCommand = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:removeArgs];
    [removeTestSleepCommand waitUntilExit];
    STAssertEquals([removeTestSleepCommand terminationStatus], 0,
                   @"Failed to remove testjob with label %@ to launchctl", label);
    
}

-(void)testLaunchctlLoadUnloadOperation
{
    LCSTestdir* testdir = [[LCSTestdir alloc] init];
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    NSString *path = [[[testdir path] stringByAppendingPathComponent:label] stringByAppendingString:@".plist"];

    NSArray *programArguments = [NSArray arrayWithObjects:@"/bin/sleep", @"10", nil];
    NSDictionary *launchdPlist = [NSDictionary dictionaryWithObjectsAndKeys:
                                  label, @"Label", programArguments, @"ProgramArguments", nil];

    NSData *launchdPlistData = [NSPropertyListSerialization dataFromPropertyList:launchdPlist
                                                                          format:NSPropertyListXMLFormat_v1_0
                                                                errorDescription:nil];
    STAssertNotNil(launchdPlistData, @"%@", @"plist data should not be nil here");
    STAssertTrue([launchdPlistData writeToFile:path atomically:TRUE], @"%@",
                 @"impossible to continue if testfile was not wirtten properly");

    /* test load operation */
    LCSLaunchctlLoadOperation *loadop = [[LCSLaunchctlLoadOperation alloc] init];
    loadop.delegate = self;
    loadop.path = [[LCSSimpleOperationInputParameter alloc] initWithValue:path];
    [loadop start];

    STAssertNil(error, @"%@", @"No error expected here");
    NSArray *infoArray = [NSArray arrayWithObjects:@"list", label, nil];
    NSTask *infoTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:infoArray];
    [infoTask waitUntilExit];
    STAssertEquals([infoTask terminationStatus], 0, @"Failed to gather info for job %@ from launchctl", label);

    /* test unload operation */
    LCSLaunchctlUnloadOperation *unloadop = [[LCSLaunchctlUnloadOperation alloc] init];
    unloadop.delegate = self;
    unloadop.path = [[LCSSimpleOperationInputParameter alloc] initWithValue:path];
    [unloadop start];

    STAssertNil(error, @"%@", @"No error expected here");
    
    [testdir remove];
    [testdir release];
}

-(void)testLaunchctlLoadUnloadOperationPathNotExisting
{
    LCSTestdir* testdir = [[LCSTestdir alloc] init];
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    NSString *path = [[[testdir path] stringByAppendingPathComponent:label] stringByAppendingString:@".plist"];

    /* test load operation */
    LCSLaunchctlLoadOperation *loadop = [[LCSLaunchctlLoadOperation alloc] init];
    loadop.delegate = self;
    loadop.path = [[LCSSimpleOperationInputParameter alloc] initWithValue:path];
    [loadop start];

    STAssertNotNil(error, @"%@", @"Error should be set if load of not existing plist file is attempted");

    [error release];
    error = nil;

    /* test unload operation */
    LCSLaunchctlUnloadOperation *unloadop = [[LCSLaunchctlUnloadOperation alloc] init];
    unloadop.delegate = self;
    unloadop.path = [[LCSSimpleOperationInputParameter alloc] initWithValue:path];
    [unloadop start];
    
    STAssertNotNil(error, @"%@", @"Error should be set if load of not existing plist file is attempted");
    
    [testdir remove];
    [testdir release];
}

-(void)testLaunchctlRemoveOperation
{
    srandom(time(NULL));

    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];

    NSArray *submitArgs = [NSArray arrayWithObjects:@"submit", @"-l", label, @"--", @"/bin/sleep", @"10", nil];
    NSTask *submitTestSleepCommand = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:submitArgs];
    [submitTestSleepCommand waitUntilExit];
    STAssertEquals([submitTestSleepCommand terminationStatus], 0,
                   @"Failed to submit testjob with label %@ to launchctl", label);

    LCSLaunchctlRemoveOperation *op = [[LCSLaunchctlRemoveOperation alloc] init];
    op.delegate = self;
    op.label = [[LCSSimpleOperationInputParameter alloc] initWithValue:label];
    [op start];

    STAssertNil(error, @"%@", @"No error expected here");
    NSArray *infoArray = [NSArray arrayWithObjects:@"list", label, nil];
    NSTask *infoTask = [NSTask launchedTaskWithLaunchPath:@"/bin/launchctl" arguments:infoArray];
    [infoTask waitUntilExit];
    STAssertEquals([infoTask terminationStatus], 1, @"launchctl info for removed job %@ must return non-zero status", label);
}

-(void)testLaunchctlRemoveOperationJobNotExisting
{
    srandom(time(NULL));
    
    NSString *label = [NSString stringWithFormat:@"ch.znerol.testjob.%0X", random()];
    
    LCSLaunchctlRemoveOperation *op = [[LCSLaunchctlRemoveOperation alloc] init];
    op.delegate = self;
    op.label = [[LCSSimpleOperationInputParameter alloc] initWithValue:label];
    [op start];
    
    STAssertNotNil(error, @"%@", @"Operation must report an error launchctl job was not found");    
}
@end
