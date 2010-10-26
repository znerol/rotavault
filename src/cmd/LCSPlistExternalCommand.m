//
//  LCSPlistExternalCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 27.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPlistExternalCommand.h"
#import "LCSCommand.h"
#import "LCSRotavaultError.h"


@implementation LCSPlistExternalCommand
-(void)dealloc
{
    [stdoutPlist release];
    [super dealloc];
}

-(void)collectResults
{
    self.result = stdoutPlist;
}

-(void)stdoutDataAvailable:(NSData *)data
{
    NSString *errorDescription;
    NSPropertyListFormat format;
    
    stdoutPlist = [NSPropertyListSerialization propertyListFromData:data
                                                   mutabilityOption:0
                                                             format:&format
                                                   errorDescription:&errorDescription];
    if (!stdoutPlist) {
        NSError *err = LCSERROR_METHOD(LCSRotavaultErrorDomain, LCSPropertyListParseError,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Failed to parse output of %@ into a property list. ", [task launchPath], errorDescription),
                                       LCSERROR_EXECUTABLE_LAUNCH_PATH([task launchPath]));
        [self handleError:err];
        [errorDescription release];
    }
    else {
        [stdoutPlist retain];
    }
}
@end
