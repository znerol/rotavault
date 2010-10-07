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
    
    LCSSignalHandler *sighandler = [LCSSignalHandler defaultSignalHandler];
    [sighandler addSignal:SIGHUP];
    [sighandler addSignal:SIGINT];
    [sighandler addSignal:SIGTERM];
    [sighandler setDelegate:self];
    
    return self;
}

-(void)dealloc
{
    [cmd release];
    [ctl release];
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

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != ctl || ![keyPath isEqualToString:@"progressMessage"]) {
        return;
    }
    
    NSLog(@"%@", ctl.progressMessage);
}

-(NSError*)run
{
    ctl = [[mgr run:cmd] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleControllerFailedNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
    [ctl addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
    
    [mgr waitUntilAllCommandsAreDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ctl removeObserver:self forKeyPath:@"progressMessage"];
    return ctl.error;
}

-(void)handleSignal:(NSNumber*)num
{
    NSLog(@"Got Signal %d, cancelling", [num intValue]);
    [cmd cancel];
}
@end
