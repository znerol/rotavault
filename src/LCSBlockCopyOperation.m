//
//  LCSBlockCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperation.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSBlockCopyOperation
@synthesize source;
@synthesize target;

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    source = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(source);
    
    target = [[LCSOperationRequiredInputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(target);
    return self;
}

-(void)dealloc
{
    [source release];
    [target release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/asr"];
    [task setArguments:[NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", @"--source",
                       source.inValue, @"--target", target.inValue, nil]];
    [super taskSetup];
}

-(void)updateStandardOutput:(NSData*)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    float progress;
    while (![scanner isAtEnd]) {
        if([scanner scanString:@"PINF" intoString:nil]) {
            [scanner scanFloat:&progress];
            [self updateProgress:progress];            
        }
        else {
            [scanner scanUpToString:@"PINF" intoString:nil];
        }
    }    
    [str release];
}
@end
