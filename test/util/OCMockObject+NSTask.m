//
//  OCMock+NSTask.m
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "OCMockObject+NSTask.h"
#import "LCSInitMacros.h"

@interface LCSTaskMockStdioHelper : NSObject {
    NSTask *task;
    NSData *stdoutData;
    NSData *stderrData;
}
+(LCSTaskMockStdioHelper*)stdioHelperWithTask:(NSTask*)task stdoutData:(NSData*)stdoutData stderrData:(NSData*)stderrData;
-(id)initWithTask:(NSTask*)task stdoutData:(NSData*)stdoutData stderrData:(NSData*)stderrData;
-(void)writeDataAndClose;
@end

@implementation LCSTaskMockStdioHelper
+(LCSTaskMockStdioHelper*)stdioHelperWithTask:(NSTask*)inTask stdoutData:(NSData*)stdoutData stderrData:(NSData*)stderrData
{
    return [[[LCSTaskMockStdioHelper alloc] initWithTask:inTask stdoutData:stdoutData stderrData:stderrData] autorelease];
}

-(id)initWithTask:(NSTask*)newTask stdoutData:(NSData*)inStdout stderrData:(NSData*)inStderr
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    task = [newTask retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(task);
    
    stdoutData = [inStdout retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(stdoutData);
    
    stderrData = [inStderr retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(stderrData);
    
    return self;
}

-(void)dealloc
{
    [task release];
    [stdoutData release];
    [stderrData release];
    [super dealloc];
}

-(void)writeDataAndClose
{
    /*
     * FIXME: It looks like its possible to deadlock here if closeFile is used... Use unix' close function
     */
    [[[task standardOutput] fileHandleForWriting] writeData:stdoutData];
    //[[[task standardOutput] fileHandleForWriting] closeFile];
    close([[[task standardOutput] fileHandleForWriting] fileDescriptor]);
    
    [[[task standardError] fileHandleForWriting] writeData:stderrData];
    //[[[task standardError] fileHandleForWriting] closeFile];
    close([[[task standardError] fileHandleForWriting] fileDescriptor]);
}
@end


@implementation OCMockObject (NSTask)
+(id)mockTask:(NSTask*)task withTerminationStatus:(int)terminationStatus stdoutData:(NSData*)stdoutData
   stderrData:(NSData*)stderrData
{
    id mock = [OCMockObject partialMockForObject:task];
    
    LCSTaskMockStdioHelper *helper = [LCSTaskMockStdioHelper stdioHelperWithTask:task
                                                                      stdoutData:stdoutData
                                                                      stderrData:stderrData];
    
    id record = [mock expect];
    record = [record andPost:[NSNotification notificationWithName:NSTaskDidTerminateNotification object:mock]];
    record = [record andCall:@selector(writeDataAndClose) onObject:helper];
    [record launch];
    
    [[[mock stub] andReturnValue:[NSValue valueWithBytes:&terminationStatus objCType:@encode(int)]] terminationStatus];
    
    BOOL no = NO;
    [[[mock stub] andReturnValue:[NSValue valueWithBytes:&no objCType:@encode(BOOL)]] isRunning];
    
    return mock;
}
@end
