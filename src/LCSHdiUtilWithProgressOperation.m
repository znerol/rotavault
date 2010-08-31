//
//  LCSHdiUtilWithProgressOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilWithProgressOperation.h"
#import "LCSOperationParameterMarker.h"
#import "LCSSimpleOperationParameter.h"


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

-(id)init
{
    self = [super init];
    path = [[LCSOperationRequiredInputParameterMarker alloc] init];
    sectors = [[LCSOperationRequiredInputParameterMarker alloc] init];
    return self;
}

-(void)dealloc
{
    [path release];
    [sectors release];
    [super dealloc];
}

-(void)taskSetup
{
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"create", path.value,
                        @"-puppetstrings",
                        @"-sectors",[sectors.value stringValue],
                        @"-type", @"UDIF",
                        @"-layout", @"NONE",
                        @"-encryption", @"AES-256", nil]];
    [super taskSetup];
}
@end

