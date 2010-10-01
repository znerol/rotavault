//
//  OCMock+NSTask.m
//  rotavault
//
//  Created by Lorenz Schori on 01.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "OCMockObject+NSTask.h"
#import "LCSInitMacros.h"

@interface LCSTaskMockPipeHelper : NSObject {
    NSData* data;
    NSPipe* pipe;
}

+(LCSTaskMockPipeHelper*)helperWithData:(NSData*)pipeData pipe:(NSPipe*)pipeObject;
-(id)initWithData:(NSData*)pipeData pipe:(NSPipe*)pipeObject;
-(void)writeDataAndClose;

@property(retain) NSData* data;
@property(retain) NSPipe* pipe;
@end

@implementation LCSTaskMockPipeHelper
+(LCSTaskMockPipeHelper*)helperWithData:(NSData*)pipeData pipe:(NSPipe*)pipeObject
{
    return [[[LCSTaskMockPipeHelper alloc] initWithData:pipeData pipe:pipeObject] autorelease];
}

-(id)initWithData:(NSData*)pipeData pipe:(NSPipe*)pipeObject
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    data = [pipeData retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(data);
    
    pipe = [pipeObject retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(pipe);
    
    return self;    
}

-(void)dealloc
{
    [data release];
    [pipe release];
    [super dealloc];
}

-(void)writeDataAndClose
{
    NSAssert(pipe != nil, @"Pipe must be set before writeData is called");
    
    [[pipe fileHandleForWriting] writeData:data];
    [[pipe fileHandleForWriting] closeFile];
}

@synthesize data;
@synthesize pipe;
@end


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
+(id)mockTaskWithTerminationStatus:(int)terminationStatus
{
    id mock = [OCMockObject mockForClass:[NSTask class]];
    [[[mock expect] andPost:[NSNotification notificationWithName:NSTaskDidTerminateNotification object:mock]] launch];
    
    [[[mock stub] andReturnValue:[NSValue valueWithBytes:&terminationStatus objCType:@encode(int)]] terminationStatus];
     
    return mock;
}

+(id)mockTaskWithTerminationStatus:(int)terminationStatus
                        stdoutData:(NSData*)stdoutData
                        stdoutPipe:(NSPipe*)stdoutPipe
                        stderrData:(NSData*)stderrData
                        stderrPipe:(NSPipe*)stderrPipe
{
    id mock = [OCMockObject mockForClass:[NSTask class]];
    LCSTaskMockPipeHelper *stdoutHelper = [LCSTaskMockPipeHelper helperWithData:stdoutData pipe:stdoutPipe];
    LCSTaskMockPipeHelper *stderrHelper = [LCSTaskMockPipeHelper helperWithData:stderrData pipe:stderrPipe];
    
    id record = [mock expect];
    record = [record andPost:[NSNotification notificationWithName:NSTaskDidTerminateNotification object:mock]];
    record = [record andCall:@selector(writeDataAndClose) onObject:stdoutHelper];
    record = [record andCall:@selector(writeDataAndClose) onObject:stderrHelper];
    [record launch];
    
    [[[mock stub] andReturnValue:[NSValue valueWithBytes:&terminationStatus objCType:@encode(int)]] terminationStatus];
     
    return mock;
}

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
