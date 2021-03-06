//
//  LCSAllRAIDInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAppleRAIDListCommand.h"
#import "LCSCommand.h"
#import "LCSInitMacros.h"
#import "LCSOSMacros.h"
#import "LCSRotavaultError.h"
#import "NSScanner+AppleRAID.h"


@implementation LCSAppleRAIDListCommand
+ (LCSAppleRAIDListCommand*)command
{
    return [[[LCSAppleRAIDListCommand alloc] init] autorelease];
}

- (id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    
    if (LCSOSSnowLeopardOrLater) {
        [task setArguments:[NSArray arrayWithObjects:@"appleRAID", @"list", nil]];
    }
    else {
        [task setArguments:[NSArray arrayWithObjects:@"listRAID", nil]];
    }
    
    return self;
}

-(void)collectResults
{
    NSString *output = [[[NSString alloc] initWithData:stdoutData encoding:NSUTF8StringEncoding] autorelease];
    NSScanner *scanner = [NSScanner scannerWithString:output];
    
    NSArray *arraylist;
    BOOL ok = [scanner scanAppleRAIDList:&arraylist];
    if (!ok) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to parse output of diskutil command"),
                                       LCSERROR_LOCALIZED_FAILURE_REASON(output),
                                       LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]),
                                       nil);
        [self handleError:err];
        return;
    }
    else if ([self.task terminationStatus] == 1 && [self validateNextState:LCSCommandStateFinished]) {
        /* 
         * diskutil appleraid list returns 1 if no raid sets are found in the system. Therefore we need to explicitely
         * switch to state finished, otherwise LCSCommand would interpret that case as a failure.
         */
        self.state = LCSCommandStateFinished;
    }
    
    self.result = arraylist;
}
@end
