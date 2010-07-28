//
//  DiskServiceTest.m
//  rotavault
//
//  Created by Lorenz Schori on 21.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskServiceTest.h"
#import "LCSDiskService.h"


@implementation LCSDiskServiceTest
- (void) testInfoForFirstDisk
{
    LCSDiskService *ds = [[LCSDiskService alloc] init];
    NSArray *disks = [ds listDisks];
    STAssertTrue([disks count] > 0, @"Must list at least one disk (e.g. startup disk)");
    NSDictionary *info = [ds diskInfo:[disks objectAtIndex:0]];
    STAssertNotNil(info, @"Disk info must not return nil");
                          
}
@end
