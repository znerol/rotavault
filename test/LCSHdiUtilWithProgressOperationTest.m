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
#import "LCSTaskOperation+TestPassword.h"


@implementation LCSHdiUtilWithProgressOperationTest
- (void)setUp
{
    testdir = [[LCSTestdir alloc] init];
}

- (void)tearDown
{
    [testdir remove];
    [testdir release];
}

-(void)testCreateEncryptedImageOperation
{
    NSString *imgpath = [[testdir path] stringByAppendingPathComponent:@"crypt.dmg"];

    LCSCreateEncryptedImageOperation *createop =
        [[LCSCreateEncryptedImageOperation alloc] initWithPath:imgpath sectors:2000];
    [createop injectTestPassword:@"TEST"];
    [createop start];

    STAssertNil(createop.error, @"Failed to create a new test-image: LCSCreateEncryptedImageOperation reported an "
                @"error");
/*    STAssertEquals(createop.progress, (float)100.0, @"Progress should be at 100.0 after creating the image"); */
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:imgpath], @"Failed to create a new test-image: file "
                 @"was not created at path @%", imgpath);

    LCSAttachImageOperation *wrongop = [[LCSAttachImageOperation alloc] initWithPathToDiskImage:imgpath];
    [wrongop injectTestPassword:@"WRONG"];
    [wrongop start];

    STAssertNotNil(wrongop.error, @"LCSAttachImageOperation must report an error if password is wrong");
    STAssertEquals([wrongop.error class], [LCSTaskOperationError class], @"reported error must be a "
                   @"LCSTaskOperationError");
    STAssertEquals([wrongop.error code], (NSInteger)LCSExecutableReturnedNonZeroStatus, @"reported error code must be "
                   @"LCSExecutableReturnedNonZeroStatus");
    NSLog(@"localizedDescription: %@", [wrongop.error localizedDescription]);
    NSLog(@"localizedFailureReason: %@", [wrongop.error localizedFailureReason]);

    LCSAttachImageOperation *attachop = [[LCSAttachImageOperation alloc] initWithPathToDiskImage:imgpath];
    [attachop injectTestPassword:@"TEST"];
    [attachop start];

    STAssertNil(attachop.error, @"Failed to attach test-image: LCSAttachImageOperation reported an error");
    STAssertNotNil(attachop.result, @"LCSAttachImageOperation should report results");
    STAssertTrue([attachop.result isKindOfClass:[NSDictionary class]], @"result of LCSAttachImageOperation must be a "
                 @"dictionary");
    NSString* devpath = [[[attachop.result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
    STAssertNotNil(devpath, @"Failed to retreive the device path of the newly attached test image");

    LCSDetachImageOperation *detachop = [[LCSDetachImageOperation alloc] initWithDevicePath:devpath];
    [detachop start];

    STAssertNil(detachop.error, @"Failed to detach test-image: LCSDetachImageOperation reported an error");

    [createop release];
    [wrongop release];
    [detachop release];
}
@end
