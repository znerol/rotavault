//
//  LCSLaunchctlInfoCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSLaunchctlInfoCommand.h"
#import "LCSInitMacros.h"


@implementation LCSLaunchctlInfoCommand
-(id)initWithLabel:(NSString*)label
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/bin/launchctl"];
    [task setArguments:[NSArray arrayWithObjects:@"list", @"-x", label, nil]];
    
    return self;
}

+(LCSLaunchctlInfoCommand*)commandWithLabel:(NSString*)label
{
    return [[[LCSLaunchctlInfoCommand alloc] initWithLabel:label] autorelease];
}

-(void)stdoutDataAvailable:(NSData *)data
{
    /*
     * launchd list -x <label> displays information about the specified job in plist/xml format. Surprisingly enough
     * this information gets written to stderr instead of stdout. Because of that we send stdout to /dev/null here and
     * instead collect the input via stderr handler.
     */
    
    /* do nothing */
}

-(void)stderrDataAvailable:(NSData *)data
{
    /* Yes, we call [super updateStandardOutput] intentionally here. See the comment from updateStandardOutput above */
    [super stdoutDataAvailable:data];
    stderrCollected = YES;
}
@end
