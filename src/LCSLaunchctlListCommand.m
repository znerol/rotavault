//
//  LCSLaunchctlListCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlListCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"
#import "LCSCommandController.h"


@implementation LCSLaunchctlListCommand
-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObject:@"list"]];
    
    return self;
}

+(LCSLaunchctlListCommand*)command
{
    return [[[LCSLaunchctlListCommand alloc] init] autorelease];
}

-(void)dealloc
{
    [joblist release];
    [super dealloc];
}

-(void)collectResults
{
    controller.result = [[joblist copy] autorelease];
}

-(void)stdoutDataAvailable:(NSData *)data
{
    NSString *stdoutString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSScanner *scanner = [NSScanner scannerWithString:stdoutString];
    [scanner setCharactersToBeSkipped:nil];
    
    /* scan header */
    if (![scanner isAtEnd]) {
        if (![scanner scanString:@"PID\tStatus\tLabel\n" intoString:nil]) {
            return;
        }
    }
    
    joblist = [[NSMutableArray alloc] init];
    while (![scanner isAtEnd]) {
        NSNumber *pid=nil;
        NSNumber *status=nil;
        NSNumber *signal=nil;
        NSString *label=nil;
        NSInteger i;
        
        /* scan pid */
        if ([scanner scanInteger:&i]) {
            pid = [NSNumber numberWithInteger:i];
        }
        else if(![scanner scanString:@"-" intoString:nil]) {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse value in pid column"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        if (![scanner scanString:@"\t" intoString:nil]) {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse column separator"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        /* minus: either no status or signal (on negative number) */
        if ([scanner scanString:@"-" intoString:nil]) {
            if ([scanner scanInteger:&i]) {
                signal = [NSNumber numberWithInteger:i];
            }
        }
        else if ([scanner scanInteger:&i]) {
            status = [NSNumber numberWithInteger:i];
        }
        else {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse value in signal column"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        if (![scanner scanString:@"\t" intoString:nil]) {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse column separator"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        /* scan label */
        if (![scanner scanCharactersFromSet:[[NSCharacterSet newlineCharacterSet] invertedSet]
                                 intoString:&label]) {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse value in label column"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        if (![scanner scanString:@"\n" intoString:nil]) {
            NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                           LCSERROR_LOCALIZED_FAILURE_REASON(@"Failed to parse newline"),
                                           LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
            [self handleError:err];
            return;
        }
        
        NSMutableDictionary *job = [NSMutableDictionary dictionaryWithObject:label forKey:@"Label"];
        if (pid) {
            [job setObject:pid forKey:@"PID"];
        }
        if (status) {
            [job setObject:status forKey:@"Status"];
        }
        if (signal) {
            [job setObject:signal forKey:@"Signal"];
        }
        
        [joblist addObject:[[job copy] autorelease]];
    }
    
    stdoutCollected = YES;
}
@end
