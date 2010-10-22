//
//  LCSCommandCollection.h
//  rotavault
//
//  Created by Lorenz Schori on 07.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


extern NSString* LCSCommandCollectionOriginalSenderKey;

@interface LCSCommandCollection : NSObject {
    NSMutableSet *commands; // set of observed commands
    NSMutableDictionary *watchers; // key:state value: set of commands which entered that state at least once
}

+(LCSCommandCollection*)collection;

-(void)addCommand:(LCSCommand*)commandCommand;
-(void)removeCommand:(LCSCommand*)commandCommand;
-(void)watchState:(LCSCommandState)state;
-(void)unwatchState:(LCSCommandState)state;

@property(readonly) NSMutableSet *commands;

+(NSString*)notificationNameAnyCommandEnteredState:(LCSCommandState)state;
+(NSString*)notificationNameAllCommandsEnteredState:(LCSCommandState)state;
@end
