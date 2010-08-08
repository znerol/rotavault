//
//  LCSHdiUtilInfoOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilInfoOperationTest.h"
#import "LCSHdiUtilInfoOperation.h"


@implementation LCSHdiUtilInfoOperationTest

- (void)setUp
{
    testdir = [[LCSTestdir alloc] init];
    imgpath = [[[testdir path] stringByAppendingPathComponent:@"test.dmg"] retain];
    
    /*
     * Interesting detail: when creating an image with apple partition table (-layout SPUD) then the whole-disk entry
     * will not be the dict at array index 0, instead it will be at array index 1! Because of that oddity, we test with
     * a GUID partition table (-layout GPTSPUD).
     */
    NSArray *args = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", imgpath, @"-plist", 
                     @"-layout", @"GPTSPUD", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *op = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    [op start];
    STAssertNil(op.error, @"Failed to create a new test-image");
    devpath = [[[op.result objectForKey:@"system-entities"] objectAtIndex:0] objectForKey:@"dev-entry"];
    STAssertNotNil(devpath, @"Failed to retreive the device path of the newly created test image");
    devpath = [devpath retain];

    [op release];
}

- (void)tearDown
{
    NSArray *args = [NSArray arrayWithObjects:@"detach", devpath, nil];

    LCSPlistTaskOperation *op = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    [op start];
    [op release];

    [imgpath release];
    [devpath release];

    [testdir remove];
    [testdir release];
}

- (void)testHdiInfoOperation
{
    LCSHdiInfoOperation *op = [[LCSHdiInfoOperation alloc] init];
    [op start];

    STAssertNil(op.error, @"LCSHdiUtilInfoOperation never should report any errors");
    STAssertNotNil(op.result, @"LCSHdiUtilInfoOperation should report results");
    STAssertTrue([op.result isKindOfClass:[NSDictionary class]], @"result of LCSHdiUtilInfoOperation must be a "
                 @"dictionary");
    STAssertTrue([[op.result objectForKey:@"images"] isKindOfClass:[NSArray class]], @"Vaule for images of the "
                 @"resulting dictionary of LCSHdiUtilInfoOperation must be an array");

    [op release];
}

-(void)testLCSHdiInfoForImageOperation
{
    LCSHdiInfoForImageOperation *op = [[LCSHdiInfoForImageOperation alloc] initWithPathToDiskImage:imgpath];
    [op start];

    STAssertNil(op.error, @"LCSHdiInfoForImageOperation should not report an error");
    STAssertNotNil(op.result, @"LCSHdiInfoForImageOperation should report results");
    STAssertTrue([op.result isKindOfClass:[NSDictionary class]], @"result of LCSHdiInfoForImageOperation must be a "
                 @"dictionary");
    STAssertTrue([[op.result objectForKey:@"image-path"] isEqualToString:imgpath], @"The image path property must be "
                 @"identical to the path to our test image");

    [op release];
}

-(void)testLCSHdiDeviceForImageOperation
{
    LCSHdiDeviceForImageOperation *op = [[LCSHdiDeviceForImageOperation alloc] initWithPathToDiskImage:imgpath];
    [op start];

    STAssertNil(op.error, @"LCSHdiDeviceForImageOperation should not report an error");
    STAssertNotNil(op.result, @"LCSHdiDeviceForImageOperation should report results");
    STAssertTrue([op.result isKindOfClass:[NSArray class]], @"result of LCSHdiInfoForImageOperation must be an "
                 @"array");
    STAssertTrue([op.result count] == 2, @"The resulting array should contain three entries");
    STAssertTrue([[op.result objectAtIndex:0] isEqualToString:devpath], @"The first item in the result must be the "
                 @"device path to our test image");

    [op release];
}

@end
