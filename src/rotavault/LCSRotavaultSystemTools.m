//
//  LCSRotavaultSystemToolsInstaller.m
//  rotavault
//
//  Created by Lorenz Schori on 22.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSRotavaultSystemTools.h"
#import "LCSPkgInfoCommand.h"

extern double RotavaultVersionNumber;

@implementation LCSRotavaultSystemTools
@synthesize installedVersion;
@synthesize requiredVersion;
@synthesize installed;
@synthesize upToDate;

-(void)updateControls
{
    self.installedVersion = installedVersion;
    self.requiredVersion = RotavaultVersionNumber;
    self.installed = installed;
    self.upToDate = installed && (installedVersion == RotavaultVersionNumber);
}

-(void)dealloc
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [currentCommand release];
    [super dealloc];
}

-(void)checkInstalledVersion
{
    if (currentCommand != nil) {
        /* don't run more than one command on a single job */
        return;
    }
    
    currentCommand = [LCSPkgInfoCommand commandWithPkgId:@"ch.znerol.rotavault.systools"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(invalidateCheckStatus:)
                                                 name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                               object:currentCommand];
    currentCommand.title = [NSString localizedStringWithFormat:@"Checking Rotavault System Tools Installation"];
    
    [currentCommand retain];
    [currentCommand start];
    [self updateControls];
}

- (void)invalidateCheckStatus:(NSNotification*)ntf
{
    assert(currentCommand == [ntf object]);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommand notificationNameStateEntered:LCSCommandStateInvalidated]
                                                  object:currentCommand];
    
    installed = (currentCommand.exitState == LCSCommandStateFinished);
    if (installed) {
        NSNumber *version = [currentCommand.result objectForKey:@"pkg-version"];
        installedVersion = [version doubleValue];
    }
    
    [currentCommand autorelease];
    currentCommand = nil;
    
    [self updateControls];
}

- (void)setAutocheck:(BOOL)value
{
    if (value == autocheck) {
        return;
    }
    autocheck = value;
    
    if (autocheck == YES) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                            selector:@selector(checkInstalledVersion)
                                                                name:@"PKInstallDaemonDidEndInstallNotification"
                                                            object:nil];
    }
    else {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:self
                                                                   name:@"PKInstallDaemonDidEndInstallNotification"
                                                                 object:nil];
    }
}

- (BOOL)autocheck
{
    return autocheck;
}
@end
