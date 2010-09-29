//
//  LCSDiskImageInfoCommandTest.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskImageInfoCommandTest.h"


@implementation LCSDiskImageInfoCommandTest

-(void)setUp
{
    states = [[NSMutableArray alloc] init];
    
    mgr = [[LCSCommandManager alloc] init];
    cmd = [[LCSDiskImageInfoCommand alloc] init];
    ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    
    [mgr addCommandController:ctl];
    [ctl addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
}

-(void)tearDown
{
    [ctl removeObserver:self forKeyPath:@"state"];
    
    [ctl release];
    ctl = nil;
    [cmd release];
    cmd = nil;
    [mgr release];
    mgr = nil;
    
    [states release];
    states = nil;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != ctl) {
        return;
    }
    
    if ([keyPath isEqualToString:@"state"]) {
        [states addObject:[NSNumber numberWithInt:ctl.state]];
    }
}

-(void)testDiskImageInfoCommand
{
    [ctl start];
    [mgr waitUntilAllCommandsAreDone];
    
    GHAssertTrue([ctl.result isKindOfClass:[NSDictionary class]], @"Result should be a dictionary");
    GHAssertTrue([[ctl.result valueForKey:@"images"] isKindOfClass:[NSArray class]],
                 @"Result should contain an array for the key 'images'");
}
@end
