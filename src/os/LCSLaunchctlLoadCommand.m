//
//  LCSLaunchctlLoad.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlLoadCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"


@implementation LCSLaunchctlLoadCommand
-(id)initWithPath:(NSString*)plistPath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"load", plistPath, nil]];
    
    return self;
}

+(LCSLaunchctlLoadCommand*)commandWithPath:(NSString*)plistPath
{
    return [[[LCSLaunchctlLoadCommand alloc] initWithPath:plistPath] autorelease];
}

-(void)collectResults
{
    if ([stderrData length] > 0) {
        NSString *failureReason = [[NSString alloc] initWithData:stderrData encoding:NSUTF8StringEncoding];
        
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to load a launchd job: %@",
                                                                        failureReason),
                                         LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]),
                                         LCSERROR_LOCALIZED_FAILURE_REASON(failureReason));
        [self handleError:error];
        [failureReason release];
    }
    
    [super collectResults];
}
@end
