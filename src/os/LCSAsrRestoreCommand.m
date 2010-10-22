//
//  LCSAsrRestoreCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 30.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAsrRestoreCommand.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"


@implementation LCSAsrRestoreCommand

+(LCSAsrRestoreCommand*)commandWithSource:(NSString*)sourceDevice target:(NSString*)targetDevice
{
    return [[[LCSAsrRestoreCommand alloc] initWithSource:sourceDevice target:targetDevice] autorelease];
}

-(id)initWithSource:(NSString*)sourceDevice target:(NSString*)targetDevice
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    sourcedev = [sourceDevice copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(sourcedev);
    targetdev = [targetDevice copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(targetdev);
    
    [task setLaunchPath:@"/usr/sbin/asr"];
    [task setArguments:[NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", @"--source",
                        sourcedev, @"--target", targetdev, nil]];
    
    return self;    
}

-(void)handleReadCompletionNotification:(NSNotification*)ntf
{
    NSString *str = [[NSString alloc] initWithData:[[ntf userInfo] objectForKey:NSFileHandleNotificationDataItem]
                                          encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    float progress;
    while (![scanner isAtEnd]) {
        if([scanner scanString:@"PINF" intoString:nil]) {
            [scanner scanFloat:&progress];
            controller.progress = progress;
        }
        else {
            [scanner scanUpToString:@"PINF" intoString:nil];
        }
    }    
    [str release];
    
    [[stdoutPipe fileHandleForReading] readInBackgroundAndNotify];
}

-(void)dealloc
{
    [sourcedev release];
    [targetdev release];
    [stdoutPipe release];
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadCompletionNotification
                                                  object:[stdoutPipe fileHandleForReading]];
    [super invalidate];
}

-(void)start
{
    if (![controller tryStart]) {
        return;
    }
    
    stdoutPipe = [[NSPipe alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadCompletionNotification:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[stdoutPipe fileHandleForReading]];
    [[stdoutPipe fileHandleForReading] readInBackgroundAndNotify];
    [task setStandardOutput:stdoutPipe];
    [super start];
}
@end
