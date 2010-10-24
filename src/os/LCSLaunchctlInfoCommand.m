//
//  LCSLaunchctlInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlInfoCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"
#import "LCSDictionaryCreateFromLaunchdJobWithLabel.h"


@implementation LCSLaunchctlInfoCommand
-(id)initWithLabel:(NSString*)aLabel
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    label = [aLabel copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    return self;
}

+(LCSLaunchctlInfoCommand*)commandWithLabel:(NSString*)aLabel
{
    return [[[LCSLaunchctlInfoCommand alloc] initWithLabel:aLabel] autorelease];
}

-(void)performStart
{
    self.state = LCSCommandStateRunning;
    NSDictionary* jobdict = (NSDictionary*)LCSDictionaryCreateFromLaunchdJobWithLabel((CFStringRef)label);
    
    if (!jobdict) {
        LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSUnexpectedOutputReceivedError,
                        LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to retreive information for specified launchd job"));
        self.state = LCSCommandStateFailed;
    }
    else {
        self.result = jobdict;
        [jobdict release];
        self.state = LCSCommandStateFinished;
    }
    
    self.state = LCSCommandStateInvalidated;
}
@end
