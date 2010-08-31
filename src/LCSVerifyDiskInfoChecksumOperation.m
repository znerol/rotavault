//
//  LCSVerifyDiskInfoChecksumOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVerifyDiskInfoChecksumOperation.h"
#import "LCSRotavaultErrorDomain.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"

@implementation LCSVerifyDiskInfoChecksumOperation
@synthesize diskinfo;
@synthesize checksum;
-(id)init
{
    self = [super init];
    diskinfo = [[NSNull null] retain];
    checksum = [[NSNull null] retain];
    return self;
}

-(void)dealloc
{
    [diskinfo release];
    [checksum release];
    [super dealloc];
}

-(void)execute
{
    NSArray* components = [checksum.value componentsSeparatedByString:@":"];

    if ([components count] != 2) {
        NSError *err = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                       userInfo:[NSDictionary dictionary]];
        [self handleError:err];
        return;
    }

    NSString* algo = [components objectAtIndex:0];
    NSString* actual = [components objectAtIndex:1];
    NSString* expected;

    if ([algo isEqualToString:@"sha1"]) {
        expected = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:diskinfo.value] stringWithHexBytes];
    }
    else if ([algo isEqualToString:@"uuid"]) {
        expected = [diskinfo.value objectForKey:@"VolumeUUID"];
    }
    else {
        NSError *err = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                       userInfo:[NSDictionary dictionary]];
        [self handleError:err];
        return;
    }
    
    if (![actual isEqualToString:expected]) {
        NSError *err = [NSError errorWithDomain:LCSRotavaultErrorDomain code:LCSUnexpectedInputReceived
                                       userInfo:[NSDictionary dictionary]];
        [self handleError:err];
        return;
    }
}
@end
