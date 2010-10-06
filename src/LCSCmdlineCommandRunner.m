//
//  LCSCmdlineCommandRunner.m
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSCmdlineCommandRunner.h"
#import "LCSInitMacros.h"


@implementation LCSCmdlineCommandRunner
-(id)initWithCommand:(id <LCSCommand>)command
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    cmd = [command retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(cmd);
    mgr = [[LCSCommandManager alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(mgr);
    
    return self;
}

-(void)dealloc
{
    [cmd release];
    [mgr release];
    [super dealloc];
}

-(void)handleControllerFailedNotification:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    if (sender.error != nil) {
        NSLog(@"ERROR: %@", [sender.error localizedDescription]);
    }
}

-(NSError*)run
{
    LCSCommandController *ctl = [mgr run:cmd];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleControllerFailedNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    
    [mgr waitUntilAllCommandsAreDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return ctl.error;
}
@end
