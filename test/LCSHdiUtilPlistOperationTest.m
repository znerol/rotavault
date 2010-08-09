//
//  LCSHdiUtilPlistOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilPlistOperationTest.h"
#import "LCSHdiUtilPlistOperation.h"


@implementation LCSHdiUtilPlistOperationTest

- (void)setUp
{

    testdir = [[LCSTestdir alloc] init];
    imgpath = [[[testdir path] stringByAppendingPathComponent:@"test.dmg"] retain];
    
    /*
     * Interesting detail: when creating an image with apple partition table (-layout SPUD) then the whole-disk entry
     * will not be the dict at array index 0, instead it will be at array index 1! Because of that oddity, we test with
     * a GUID partition table (-layout GPTSPUD).
     */
    result = nil;
    error = nil;
    NSArray *args = [NSArray arrayWithObjects:@"create", @"-sectors", @"2000", imgpath, @"-plist", 
                     @"-layout", @"GPTSPUD", @"-fs", @"HFS+", @"-attach", nil];
    LCSPlistTaskOperation *op = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"Failed to create a new test-image");
    devpath = [[[result valueForKeyPath:@"system-entities.dev-entry"]
                sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:0];
    STAssertNotNil(devpath, @"Failed to retreive the device path of the newly created test image");
    devpath = [devpath retain];

    [op release];

    if(result) {
        [result release];
        result = nil;
    }
    if(error) {
        [error release];
        error = nil;
    }
}

- (void)tearDown
{
    NSArray *args = [NSArray arrayWithObjects:@"detach", devpath, nil];

    if(result) {
        [result release];
        result = nil;
    }
    if(error) {
        [error release];
        error = nil;
    }
    
    LCSPlistTaskOperation *op = [[LCSPlistTaskOperation alloc] initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    [op start];
    [op release];

    [imgpath release];
    [devpath release];

    [testdir remove];
    [testdir release];
}

-(void)taskOperation:(LCSTaskOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

-(void)taskOperation:(LCSTaskOperation*)operation handleResult:(id)inResult
{
    result = [inResult retain];
}

- (void)testHdiInfoOperation
{
    LCSHdiInfoOperation *op = [[LCSHdiInfoOperation alloc] init];
    [op setDelegate:self];
    [op start];

    STAssertNil(error, @"LCSHdiUtilPlistOperation never should report any errors");
    STAssertNotNil(result, @"LCSHdiUtilPlistOperation should report results");
    STAssertTrue([result isKindOfClass:[NSDictionary class]], @"result of LCSHdiUtilPlistOperation must be a "
                 @"dictionary");
    STAssertTrue([[result objectForKey:@"images"] isKindOfClass:[NSArray class]], @"Vaule for images of the "
                 @"resulting dictionary of LCSHdiUtilPlistOperation must be an array");

    [op release];
}

@end
