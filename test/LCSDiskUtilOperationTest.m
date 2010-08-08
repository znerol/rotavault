//
//  LCSDiskUtilOperationTest.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperationTest.h"
#import "LCSDiskUtilOperation.h"


@implementation LCSDiskUtilOperationTest
- (void) testListDisks
{
    LCSListDisksOperation *op = [[LCSListDisksOperation alloc] init];
    [op start];
    STAssertNil(op.error, @"LCSListDiskOperation should not cause any errors");
    STAssertNotNil(op.result, @"LCSListDiskOperation must return a result");
    STAssertTrue([op.result isKindOfClass:[NSArray class]], @"Result of LCSListDiskOperation must be an array");
    STAssertTrue([op.result count] > 0, @"LCSListDiskOperation must report at least one entry (startup disk)");

    [op release];
}

-(void) testInfoForDisk
{
    LCSInformationForDiskOperation *op = [[LCSInformationForDiskOperation alloc] initWithDiskIdentifier:@"/dev/disk0"];
    [op start];
    STAssertNil(op.error, @"LCSInformationForDiskOperation should not cause any errors for the startup disk");
    STAssertNotNil(op.result, @"LCSInformationForDiskOperation must return a result for the startup disk");
    STAssertTrue([op.result isKindOfClass:[NSDictionary class]], @"Result of LCSInformationForDiskOperation must be a"
                   @"dictionary");
    STAssertTrue([op.result count] > 0, @"Resulting dictionary may not be empty");

    [op release];
}

@end
