//
//  LCSMultiCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSCommandController.h"


@interface LCSMultiCommand : NSObject <LCSCommand> {
    LCSCommandController *controller;
    NSArray *controllers;
    NSArray *commands;
    
    NSUInteger invalidatedCound;
    NSUInteger cancelledCount;
    NSUInteger failedCount;
    NSUInteger finishedCount;
}

+(LCSMultiCommand*)command;

@property(retain) NSArray *commands;
@property(retain) NSArray *controllers;
@end
