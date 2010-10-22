//
//  LCSRAIDAddMember.m
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSAppleRAIDAddMemberCommand.h"
#import "LCSInitMacros.h"
#import "LCSRotavaultError.h"
#import "LCSOSMacros.h"
#import "LCSCommandController.h"

@interface LCSAppleRAIDAddMemberCommand (Internal)
-(void)invalidate;
-(void)handleReadCompletionNotification:(NSNotification*)ntf;
@end


@implementation LCSAppleRAIDAddMemberCommand
+ (LCSAppleRAIDAddMemberCommand*) commandWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath
{
    return [[[LCSAppleRAIDAddMemberCommand alloc] initWithRaidUUID:raidUUID devicePath:devicePath] autorelease];
}

- (id)initWithRaidUUID:(NSString*)raidUUID devicePath:(NSString*)devicePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/sbin/diskutil"];
    
    if (LCSOSSnowLeopardOrLater) {
        [task setArguments:[NSArray arrayWithObjects:@"appleRAID", @"add", @"member", devicePath, raidUUID, nil]];
    }
    else {
        [task setArguments:[NSArray arrayWithObjects:@"addToRaid", @"member", devicePath, raidUUID, nil]];
    }
    
    return self;
}

-(void)handleReadCompletionNotification:(NSNotification*)ntf
{
    NSString *str = [[NSString alloc] initWithData:[[ntf userInfo] objectForKey:NSFileHandleNotificationDataItem]
                                          encoding:NSUTF8StringEncoding];
    
    NSArray *lines = [str componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        self.progressMessage = line;
    }
    
    [str release];
    [[stdoutPipe fileHandleForReading] readInBackgroundAndNotify];
}

-(void)dealloc
{
    [stdoutPipe release];
    [super dealloc];
}

-(void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSFileHandleReadCompletionNotification
                                                  object:[stdoutPipe fileHandleForReading]];
    [super invalidate];
}

-(void)performStart
{
    stdoutPipe = [[NSPipe alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleReadCompletionNotification:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:[stdoutPipe fileHandleForReading]];
    [[stdoutPipe fileHandleForReading] readInBackgroundAndNotify];
    [task setStandardOutput:stdoutPipe];
    [super performStart];
}
@end
