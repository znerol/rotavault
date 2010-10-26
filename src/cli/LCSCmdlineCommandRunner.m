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
#import "LCSCommand.h"
#import "LCSDistributedCommandStatePublisher.h"


@implementation LCSCmdlineCommandRunner
-(id)initWithCommand:(LCSCommand*)command label:(NSString*)lbl title:(NSString*)tit
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [title release];
    [label release];
    [cmd release];
    [super dealloc];
}

-(void)handleCommandFailedNotification:(NSNotification*)ntf
{
    LCSCommand *sender = [ntf object];
    if (sender.error != nil) {
        asl_log(NULL, NULL, ASL_LEVEL_ERR, "%s", [[sender.error localizedDescription] cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object != cmd || ![keyPath isEqualToString:@"progressMessage"]) {
        return;
    }
    
    asl_log(NULL, NULL, ASL_LEVEL_INFO, "%s", [cmd.progressMessage cStringUsingEncoding:NSUTF8StringEncoding]);
}

-(NSError*)run
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCommandFailedNotification:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateFailed]
                                               object:cmd];
        
    /* wire up command to our logging function */
    [cmd addObserver:self forKeyPath:@"progressMessage" options:0 context:nil];
    
    /* wire up command to distributed notification center */
    LCSDistributedCommandStatePublisher *pub =
        [[LCSDistributedCommandStatePublisher alloc] initWithCommand:cmd label:label];
    [pub watch];
    
    cmd.title = title;
    
    /* run */
    [cmd start];
    [cmd waitUntilDone];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [cmd removeObserver:self forKeyPath:@"progressMessage"];
    [pub unwatch];
    [pub release];
    
    return cmd.error;
}

-(void)handleSignal:(NSNumber*)num
{
    asl_log(NULL, NULL, ASL_LEVEL_INFO, "Terminating on signal %d", [num intValue]);
    [cmd cancel];
}
@end
