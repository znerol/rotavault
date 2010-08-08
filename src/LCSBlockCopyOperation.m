//
//  LCSBlockCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperation.h"


@implementation LCSBlockCopyOperation

@synthesize progress;

-(LCSBlockCopyOperation*)initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev
{
    NSArray *args = [NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", 
                     @"--source", sourcedev, @"--target", targetdev, nil];
    self = (LCSBlockCopyOperation*)[super initWithLaunchPath:@"/usr/sbin/asr" arguments:args];
    progress = -1.0;
    return self;
}

-(BOOL)parseOutput:(NSData*)data isAtEnd:(BOOL)atEnd error:(NSError**)outError
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    while (![scanner isAtEnd]) {
        if([scanner scanString:@"PINF" intoString:nil]) {
            [scanner scanFloat:&progress];
        }
        else {
            [scanner scanUpToString:@"PINF" intoString:nil];
        }
    }    
    [str release];
    return YES;
}

-(BOOL)hasProgress
{
    return YES;
}
@end
