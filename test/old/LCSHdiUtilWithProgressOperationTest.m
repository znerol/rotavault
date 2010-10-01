//
//  LCSHdiUtilWithProgressOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilWithProgressOperationTest.h"
#import "LCSHdiUtilWithProgressOperation.h"
#import "LCSHdiUtilPlistOperation.h"
#import "LCSTaskOperationBase+TestPassword.h"
#import "LCSKeyValueOperationParameter.h"
#import "LCSSimpleOperationParameter.h"
#import "LCSRotavaultError.h"


@implementation LCSHdiUtilWithProgressOperationTest
-(void)delegateCleanup
{
    if (result) {
        [result  release];
        result = nil;
    }
    if (error) {
        [error release];
        error = nil;
    }
    progress = 0.0;
}

- (void)setUp
{
    testdir = [[LCSTestdir alloc] init];
    result = nil;
    error = nil;
}

- (void)tearDown
{
    [self delegateCleanup];
    [testdir remove];
    [testdir release];
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    if (error == inError) {
        return;
    }
    [error release];
    error = [inError retain];
}

-(void)operation:(LCSOperation*)operation updateProgress:(NSNumber*)inProgress
{
    float newProgress = [inProgress floatValue];
    
    /*
     * filter out -1
     */
    if (newProgress >= 0) {
        progress = newProgress;
    }
}

-(void)testCreateEncryptedImageOperation
{
    NSString *imgpath = [[testdir path] stringByAppendingPathComponent:@"crypt.dmg"];

    LCSCreateEncryptedImageOperation *createop = [[LCSCreateEncryptedImageOperation alloc] init];
    createop.path = [LCSSimpleOperationInputParameter parameterWithValue:imgpath];
    createop.sectors = [LCSSimpleOperationInputParameter parameterWithValue:[NSNumber numberWithInt:2000]];

    [createop injectTestPassword:@"TEST"];

    [createop setDelegate:self];
    [createop start];

    STAssertNil(error, @"%@", @"Failed to create a new test-image: LCSCreateEncryptedImageOperation reported an error");
    STAssertEquals(progress, (float)100.0, @"%@", @"Progress should be at 100.0 after creating the image");
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:imgpath], @"Failed to create a new test-image: file "
                 @"was not created at path %@", imgpath);
    [self delegateCleanup];

    LCSAttachImageOperation *wrongop = [[LCSAttachImageOperation alloc] init];
    wrongop.path = [LCSSimpleOperationInputParameter parameterWithValue:imgpath];
    wrongop.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"result"];

    [wrongop injectTestPassword:@"WRONG"];

    [wrongop setDelegate:self];
    [wrongop start];

    STAssertNotNil(error, @"%@", @"LCSAttachImageOperation must report an error if password is wrong");
    STAssertEquals([error class], [NSError class], @"%@", @"reported error must be a "
                   @"LCSTaskOperationError");
    STAssertEquals([error code], (NSInteger)LCSExecutableReturnedNonZeroStatusError, @"%@", @"reported error code must be "
                   @"LCSExecutableReturnedNonZeroStatus");
    /*
    NSLog(@"localizedDescription: %@", [error localizedDescription]);
    NSLog(@"localizedFailureReason: %@", [error localizedFailureReason]);
     */
    [self delegateCleanup];

    LCSAttachImageOperation *attachop = [[LCSAttachImageOperation alloc] init];
    attachop.path = [LCSSimpleOperationInputParameter parameterWithValue:imgpath];
    attachop.result = [LCSKeyValueOperationOutputParameter parameterWithTarget:self keyPath:@"result"];
    
    [attachop injectTestPassword:@"TEST"];
    
    [attachop setDelegate:self];
    [attachop start];
    
    STAssertNil(error, @"%@", @"Failed to attach test-image: LCSAttachImageOperation reported an error");
    STAssertNotNil(result, @"%@", @"LCSAttachImageOperation should report results");
    STAssertTrue([result isKindOfClass:[NSDictionary class]], @"%@", @"result of LCSAttachImageOperation must be a "
                 @"dictionary");
    NSString* devpath = [[[[result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"] retain];
    STAssertNotNil(devpath, @"%@", @"Failed to retrieve the device path of the newly attached test image");
    [self delegateCleanup];

    LCSDetachImageOperation *detachop = [[LCSDetachImageOperation alloc] init];
    detachop.path = [LCSSimpleOperationInputParameter parameterWithValue:devpath];
    [detachop setDelegate:self];
    
    [detachop start];
    
    STAssertNil(error, @"%@", @"Failed to detach test-image: LCSDetachImageOperation reported an error");

    [devpath release];
    [createop release];
    [wrongop release];
    [attachop release];
    [detachop release];
}
@end
