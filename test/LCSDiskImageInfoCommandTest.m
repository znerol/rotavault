//
//  LCSDiskImageInfoCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import "LCSDiskImageInfoCommand.h"
#import "LCSCommandController.h"
#import "LCSCommandManager.h"


@interface LCSDiskImageInfoCommandTest : GHTestCase
@end


@implementation LCSDiskImageInfoCommandTest
-(void)testDiskImageInfoCommand
{
    LCSCommandManager *mgr = [[LCSCommandManager alloc] init];
    LCSDiskImageInfoCommand *cmd = [LCSDiskImageInfoCommand command];
    LCSCommandController *ctl = [LCSCommandController controllerWithCommand:cmd];
    
    [mgr addCommandController:ctl];
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertTrue([ctl.result isKindOfClass:[NSDictionary class]], @"Result should be a dictionary");
    GHAssertTrue([[ctl.result valueForKey:@"images"] isKindOfClass:[NSArray class]],
                 @"Result should contain an array for the key 'images'");
    
    [mgr release];
}
@end
