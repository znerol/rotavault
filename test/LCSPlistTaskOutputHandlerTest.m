//
//  LCSPlistTaskOutputHandlerTest.m
//  rotavault
//
//  Created by Lorenz Schori on 04.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOutputHandlerTest.h"
#import "LCSPlistTaskOutputHandler.h"


@implementation LCSPlistTaskOutputHandlerTest

- (void)testResultsFromTerminatedTaskWithLaunchPath
{
    NSDictionary *results = [LCSPlistTaskOutputHandler resultsFromTerminatedTaskWithLaunchPath:
        @"/usr/sbin/system_profiler" arguments:
        [NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil]];
    
    STAssertNotNil(results, @"should not return nil");
}

- (void)testFullSequence
{
    NSTask *sysprof = [[NSTask alloc] init];
    LCSPlistTaskOutputHandler *handler = [[LCSPlistTaskOutputHandler alloc] initWithTarget:sysprof];

    [sysprof setLaunchPath:@"/usr/sbin/system_profiler"];
    [sysprof setArguments:[NSArray arrayWithObjects: @"-xml", @"SPDiagnosticsDataType", nil]];
    [sysprof launch];
    [sysprof waitUntilExit];
    NSDictionary *results = [handler results];
    
    STAssertNotNil(results, @"should not return nil");
}

@end
