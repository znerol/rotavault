//
//  LCSHdiUtilWithProgressOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilWithProgressOperation.h"


@implementation LCSHdiUtilWithProgressOperation
-(void)updateStandardOutput:(NSData*)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:str];
    float   progress;
    while (![scanner isAtEnd]) {
        if([scanner scanString:@"PERCENT:" intoString:nil]) {
            [scanner scanFloat:&progress];
            [self updateProgress:progress];
        }
        else {
            [scanner scanUpToString:@"PERCENT:" intoString:nil];
        }
    }    
    [str release];
}
@end

@implementation LCSCreateEncryptedImageOperation
@synthesize path;
@synthesize sectors;

-(void)taskBuildArguments
{
    self.launchPath = @"/usr/bin/hdiutil";
    self.arguments = [NSArray arrayWithObjects:@"create", path,
                      @"-puppetstrings",
                      @"-sectors",[[NSNumber numberWithUnsignedLongLong:sectors] stringValue],
                      @"-type", @"UDIF",
                      @"-layout", @"NONE",
                      @"-encryption", @"AES-256", nil];
}
@end

