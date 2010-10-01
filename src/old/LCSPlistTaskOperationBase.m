//
//  LCSPlistTaskOperationBase.m
//  rotavault
//
//  Created by Lorenz Schori on 29.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistTaskOperationBase.h"
#import "LCSInitMacros.h"
#import "LCSOperationParameterMarker.h"
#import "LCSRotavaultError.h"


@implementation LCSPlistTaskOperationBase
@synthesize result;
@synthesize extractKeyPath;

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    _outputData = [[NSMutableData alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(_outputData);
    
    extractKeyPath = [[LCSOperationOptionalInputParameterMarker alloc] initWithDefaultValue:nil];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(extractKeyPath);
    
    result = [[LCSOperationOptionalOutputParameterMarker alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(result);

    return self;
}

-(void)dealloc
{
    [_outputData release];
    [extractKeyPath release];
    [result release];
    [super dealloc];
}

-(void)updateStandardOutput:(NSData*)data
{
    [_outputData appendData:data];
    [super updateStandardOutput:data];
}

-(void)taskOutputComplete
{
    if ([_outputData length] == 0) {
        return;
    }
    
    NSString *errorDescription;
    NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:_outputData
                                                           mutabilityOption:kCFPropertyListImmutable
                                                                     format:nil
                                                           errorDescription:&errorDescription];
    
    if (plist) {
        if (extractKeyPath.inValue != nil) {
            plist = [plist valueForKeyPath:extractKeyPath.inValue];
        }
        result.outValue = plist;
    }
    else {
        NSError *error = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSPropertyListParseError,
            LCSERROR_LOCALIZED_DESCRIPTION(errorDescription));
        [self handleError:error];
        [errorDescription release];
    }
    
    [super taskOutputComplete];
}
@end
