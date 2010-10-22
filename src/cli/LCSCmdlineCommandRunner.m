//
//  LCSCmdlineCommandRunner.m
//  rotavault
//
//  Created by Lorenz Schori on 06.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <asl.h>
#import "LCSCmdlineCommandRunner.h"
#import "LCSInitMacros.h"
#import "LCSCommandController.h"
#import "LCSDistributedCommandStatePublisher.h"


@implementation LCSCmdlineCommandRunner
-(id)initWithCommand:(<LCSCommandTemp>)command label:(NSString*)lbl title:(NSString*)tit
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    cmd = [command retain];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(cmd);
    
    label = [lbl copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(label);
    
    title = [tit copy];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(title);
    
    LCSSignalHandler *sighandler = [LCSSignalHandler defaultSignalHandler];
    [sighandler addSignal:SIGHUP];
    [sighandler addSignal:SIGINT];
    [sighandler addSignal:SIGTERM];
    [sighandler setDelegate:self];
    
    return self;
}

-(void)dealloc
{
    [title release];
    [label release];
    [cmd release];
    [ctl release];
    [super dealloc];
}

-(void)handleControllerFailedNotification:(NSNotification*)ntf
{
    LCSCommandController *sender = [ntf object];
    if (sender.error != nil) {
        asl_log(NULL, NULL, ASL_LEVEL_ERR, "%s", [[sender.error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != ctl || ![keyPath isEqualToString:@"progressMessage"]) {
        return;
    }
    
    asl_log(NULL, NULL, ASL_LEVEL_INFO, "%s", [ctl.progressMessage cStringUsingEncoding:NSUTF8StringEncoding]);
}

-(NSError*)run
{
    ctl = [[LCSCommandController controllerWithCommand:cmd] retain];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleControllerFailedNotification:)
                                                 name:[LCSCommandController notificationNameStateEntered:LCSCommandStateFailed]
                                               object:ctl];
        
    /* wire up command to our logging function */
    [ctl addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
    
    /* wire up command to distributed notification center */
    LCSDistributedCommandStatePublisher *pub =
        [[LCSDistributedCommandStatePublisher alloc] initWithCommandController:ctl label:label];
    [pub watch];
    
    ctl.title = title;
    
    /* run */
    [ctl start];
    [ctl waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [ctl removeObserver:self forKeyPath:@"progressMessage"];
    [pub unwatch];
    [pub release];
    
    return ctl.error;
}

-(void)handleSignal:(NSNumber*)num
{
    asl_log(NULL, NULL, ASL_LEVEL_INFO, "Terminating on signal %d", [num intValue]);
    [cmd cancel];
}
@end
