//
//  LCSExecuteBASCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 19.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandTemp.h"
#import "LCSCommandController.h"
#import "BetterAuthorizationSampleLib.h"


@interface LCSExecuteBASCommand : NSObject <LCSCommandTemp> {
    LCSCommandController    *controller;
    
    AuthorizationRef        authorization;
    const BASCommandSpec    *commandSet;
    NSDictionary            *request;
    NSDictionary            *response;
    
    NSString                *bundleID;
}

@property(retain) NSString* bundleID;

+ (LCSExecuteBASCommand*)commandWithRequest:(NSDictionary*)req
                                    fromSet:(BASCommandSpec*)cmdSet
                          withAuthorization:(AuthorizationRef)auth;

- (id)initWithRequest:(NSDictionary*)req fromSet:(const BASCommandSpec*)cmdSet withAuthorization:(AuthorizationRef)auth;
@end

@interface LCSExecuteBASCommand (SubclassOverride)
- (void)collectResults;
@end
