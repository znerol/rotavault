//
//  LCSBlockCopyOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyOperation.h"


@implementation LCSBlockCopyOperation

-(LCSBlockCopyOperation*)initWithSourceDevice:(NSString*)sourcedev targetDevice:(NSString*)targetdev
{
    NSArray *args = [NSArray arrayWithObjects:@"restore", @"--erase", @"--noprompt", @"--puppetstrings", 
                     @"--source", sourcedev, @"--target", targetdev, nil];
    self = (LCSBlockCopyOperation*)[super initWithLaunchPath:@"/usr/sbin/asr" arguments:args];
    return self;
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
