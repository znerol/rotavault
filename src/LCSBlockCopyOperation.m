//
//  LCSBlockCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperation.h"


@implementation LCSBlockCopyOperation
@synthesize error;
@synthesize progress;

- (LCSBlockCopyOperation*) initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev
{
    self = [super init];
    source = sourcedev;
    target = targetdev;
    error = nil;
    progress = 0;
    return self;
}

- (void) parseProgress:(NSData*)data
{
    NSString *stuff = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    NSScanner *scanner = [NSScanner scannerWithString:stuff];
    while (![scanner isAtEnd]) {
        if([scanner scanString:@"PINF" intoString:nil]) {
            [scanner scanFloat:&progress];
        }
        else {
            [scanner scanUpToString:@"PINF" intoString:nil];
        }
    }    
}

- (void) updateProgress:(NSNotification*)nfc
{
    [self parseProgress:[[nfc userInfo] objectForKey:NSFileHandleNotificationDataItem]];
}

- (void) main
{
    NSTask *asr = [[NSTask alloc] init];
    [asr setLaunchPath:@"/usr/sbin/asr"];

    NSArray *args = [NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", 
                     @"--source", source, @"--target", target, nil];

    [asr setArguments:args];

    /* install standard error pipe */
    NSPipe *errPipe = [NSPipe pipe];
    [asr setStandardError:errPipe];

    /* install progress meter */
    NSPipe *outPipe = [NSPipe pipe];
    [asr setStandardOutput:outPipe];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgress:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[outPipe fileHandleForReading]];
    [[outPipe fileHandleForReading] readInBackgroundAndNotify];

    [asr launch];
    [asr waitUntilExit];
    
    NSData* rest=[[outPipe fileHandleForReading] readDataToEndOfFile];
    [self parseProgress:rest];

    int status = [asr terminationStatus];
    if (status != 0) {
        NSString *message = [[NSString alloc] initWithData:[[errPipe fileHandleForReading] availableData]
                                                  encoding:NSUTF8StringEncoding];

        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  message, NSLocalizedDescriptionKey,nil];

        error = [NSError errorWithDomain:@"ch.znerol.rotavault.ErrorDomain" code:status userInfo:userInfo];
    }

    [asr release];
}
@end
