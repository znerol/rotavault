//
//  LCSBlockCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


@implementation LCSBlockCopyOperation
@synthesize source;
@synthesize target;

-(id)init
{
    self = [super init];
    source = [[LCSOperationRequiredInputParameterMarker alloc] init];
    target = [[LCSOperationRequiredInputParameterMarker alloc] init];
    return self;
}

-(void)dealloc
{
    [(id)source release];
    [(id)target release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/sbin/asr"];
    [task setArguments:[NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", @"--source",
                       source.value, @"--target", target.value, nil]];
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
