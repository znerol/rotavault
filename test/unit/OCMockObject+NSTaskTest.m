//
//  OCMockObject+NSTaskTest.m
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "OCMockObject+NSTask.h"

@interface OCMockObjectNSTaskTest : GHTestCase
@end


@implementation OCMockObjectNSTaskTest
-(void)testMockedTaskObjectWithTerminationStatusWithOutputData
{
    NSData *stdoutData = [@"Standard Output Test" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *stderrData = [NSData data];
    NSPipe *stdoutPipe = [NSPipe pipe];
    NSPipe *stderrPipe = [NSPipe pipe];
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/dev/null"];
    [task setArguments:[NSArray arrayWithObjects:@"-q", @"some", @"args", nil]];
    [task setStandardOutput:stdoutPipe];
    [task setStandardError:stderrPipe];
    
    id mockTask = [OCMockObject mockTask:task withTerminationStatus:23 stdoutData:stdoutData stderrData:stderrData];
    
    [mockTask launch];
    
    GHAssertEqualObjects([[stdoutPipe fileHandleForReading] readDataToEndOfFile],
                         [@"Standard Output Test" dataUsingEncoding:NSUTF8StringEncoding],
                         @"Unexpected Output received");
    GHAssertEqualObjects([[stderrPipe fileHandleForReading] readDataToEndOfFile], [NSData data],
                         @"Unexpected Output received");
    
    GHAssertEquals([mockTask terminationStatus], 23, @"Unexpected termination status");
    [mockTask verify];
    
    [task release];
}
@end
