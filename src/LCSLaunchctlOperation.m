//
//  LCSLaunchctlOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSTaskOperationError.h"


@implementation LCSLaunchctlLoadOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    if (!path) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [path release];
    [super dealloc];
}

@synthesize path;

-(void)taskSetup
{
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"load", path.value, nil]];
}
@end

@implementation LCSLaunchctlUnloadOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    if (!path) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [path release];
    [super dealloc];
}

@synthesize path;

-(void)taskSetup
{
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"unload", path.value, nil]];
}
     
@end

@implementation LCSLaunchctlRemoveOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    label = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    if (!label) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [label release];
    [super dealloc];
}

@synthesize label;

-(void)taskSetup
{
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"remove", label.value, nil]];
}
@end

@implementation LCSLaunchctlListOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    result = [[LCSOperationOptionalOutputParameterMarker alloc] init];
    stdoutData = [[NSMutableData alloc] init];
    
    if (!result) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [result release];
    [stdoutData release];
    [super dealloc];
}

@synthesize result;

-(void)taskSetup
{
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObject:@"list"]];
}

-(void)updateStandardOutput:(NSData *)data
{
    [stdoutData appendData:data];
}

-(void)taskOutputComplete
{
    NSString *stdoutString = [[NSString alloc] initWithData:stdoutData encoding:NSASCIIStringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:stdoutString];
    [scanner setCharactersToBeSkipped:nil];

    /* scan header */
    if (![scanner isAtEnd]) {
        if (![scanner scanString:@"PID\tStatus\tLabel\n" intoString:nil]) {
            return;
        }
    }

    NSMutableArray* joblist = [NSMutableArray array];
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
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse value in pid column"];
            [self handleError:err];
            return;
        }

        if (![scanner scanString:@"\t" intoString:nil]) {
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse column separator"];
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
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse value in signal column"];
            [self handleError:err];
            return;
        }

        if (![scanner scanString:@"\t" intoString:nil]) {
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse column separator"];
            [self handleError:err];
            return;
        }
        
        /* scan label */
        if (![scanner scanCharactersFromSet:[[NSCharacterSet newlineCharacterSet] invertedSet]
                                 intoString:&label]) {
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse value in label column"];
            [self handleError:err];
            return;
        }

        if (![scanner scanString:@"\n" intoString:nil]) {
            LCSTaskOperationError *err = [[LCSTaskOperationError alloc]
                                          initReceivedUnexpectedOutputFromLaunchPath:[task launchPath] 
                                          message:@"Failed to parse newline"];
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

    result.value = [[joblist copy] autorelease];
}
@end

@implementation LCSLaunchctlInfoOperation
-(id)init
{
    if (!(self = [super init])) {
        return nil;
    }
    
    label = [[LCSOperationRequiredInputParameterMarker alloc] init];
    
    if (!label) {
        [self release];
        return nil;
    }
    return self;
}

-(void)dealloc
{
    [label release];
    [super dealloc];
}

@synthesize label;

-(void)taskSetup
{
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"list", @"-x", label.value, nil]];
}

-(void)updateStandardOutput:(NSData *)data
{
    /*
     * launchd list -x <label> displays information about the specified job in plist/xml format. Surprisingly enough
     * this information gets written to stderr instead of stdout. Because of that we send stdout to /dev/null here and
     * instead collect the input via stderr handler.
     */
    
    /* do nothing */
}

-(void)updateStandardError:(NSData *)data
{
    /* Yes, we call [super updateStandardOutput] intentionally here. See the comment from updateStandardOutput above */
    [super updateStandardOutput:data];
}
@end
