//
//  LCSHdiUtilWithProgressOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilWithProgressOperation.h"


@implementation LCSHdiUtilWithProgressOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments
{
    NSArray *args = [[[NSArray arrayWithObject:command] arrayByAddingObjectsFromArray:arguments]
                     arrayByAddingObject:@"-puppetstrings"];
    self = [super initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];

    return self;
}

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
-(id)initWithPath:(NSString*)inPath sectors:(NSInteger)sectors
{
    NSArray *args = [NSArray arrayWithObjects:inPath,
                     @"-sectors",[[NSNumber numberWithInt:sectors] stringValue],
                     @"-type", @"UDIF",
                     @"-layout", @"NONE",
                     @"-encryption", @"AES-256", nil];
    self = [super initWithCommand:@"create" arguments:args];
    return self;
}
@end

