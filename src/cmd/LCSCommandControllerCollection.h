//
//  LCSCommandControllerCollection.h
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


extern NSString* LCSCommandControllerCollectionOriginalSenderKey;

@interface LCSCommandControllerCollection : NSObject {
    NSMutableSet *controllers; // set of observed controllers
    NSMutableDictionary *watchers; // key:state value: set of controllers which entered that state at least once
}

+(LCSCommandControllerCollection*)collection;

-(void)addController:(LCSCommand*)commandController;
-(void)removeController:(LCSCommand*)commandController;
-(void)watchState:(LCSCommandState)state;
-(void)unwatchState:(LCSCommandState)state;

@property(readonly) NSMutableSet *controllers;

+(NSString*)notificationNameAnyControllerEnteredState:(LCSCommandState)state;
+(NSString*)notificationNameAllControllersEnteredState:(LCSCommandState)state;
@end
