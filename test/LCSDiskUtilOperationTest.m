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


@implementation LCSDiskUtilOperationTest
-(void)setUp
{
    error = nil;
    result = nil;
}

-(void)tearDown
{
    if (error) {
        [error release];
        error = nil;
    }
    if (result) {
        [result release];
        result = nil;
    }
}

-(void)operation:(LCSOperation*)operation handleError:(NSError*)inError
{
    error = [inError retain];
}

- (void) testListDisks
{
    LCSListDisksOperation *op = [[LCSListDisksOperation alloc] init];
    [op setDelegate:self];
    op.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"result"];

    [op start];
    STAssertNil(error, @"LCSListDiskOperation should not cause any errors");
    STAssertNotNil(result, @"LCSListDiskOperation must return a result");
    STAssertTrue([result isKindOfClass:[NSArray class]], @"Result of LCSListDiskOperation must be an array");
    STAssertTrue([result count] > 0, @"LCSListDiskOperation must report at least one entry (startup disk)");

    [op release];
}

-(void) testInfoForDisk
{
    LCSInformationForDiskOperation *op = [[LCSInformationForDiskOperation alloc] init];
    [op setDelegate:self];
    op.device = [[LCSSimpleOperationInputParameter alloc] initWithValue:@"/dev/disk0"];
    op.result = [[LCSKeyValueOperationOutputParameter alloc] initWithTarget:self keyPath:@"result"];

    [op start];
    STAssertNil(error, @"LCSInformationForDiskOperation should not cause any errors for the startup disk");
    STAssertNotNil(result, @"LCSInformationForDiskOperation must return a result for the startup disk");
    STAssertTrue([result isKindOfClass:[NSDictionary class]], @"Result of LCSInformationForDiskOperation must be a"
                   @"dictionary");
    STAssertTrue([result count] > 0, @"Resulting dictionary may not be empty");

    [op release];
}

@end
