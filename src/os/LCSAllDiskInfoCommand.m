//
//  LCSRotavaultAllDiskInformationCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 11.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <glob.h>
#import "LCSAllDiskInfoCommand.h"
#import "LCSRotavaultError.h"
#import "LCSInitMacros.h"
#import "LCSDiskInfoCommand.h"

@interface LCSAllDiskInfoCommand (PrivateMethods)
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
@end

@implementation LCSAllDiskInfoCommand

+ (LCSAllDiskInfoCommand*)command
{
    return [[[LCSAllDiskInfoCommand alloc] init] autorelease];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)startGatherInformation
{
    NSParameterAssert([activeCommands.commands count] == 0);
    
    glob_t g;
    int err = glob("/dev/disk*", GLOB_NOSORT, NULL, &g);
    
    /* iterate thru disks */
    if (err != 0) {
        NSString *reason = LCSErrorLocalizedFailureReasonFromErrno(errno);
        NSError *err = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                       LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to get list of disk device nodes: %@", reason),
                                       LCSERROR_LOCALIZED_DESCRIPTION(reason));
        globfree(&g);
        [self handleError:err];
        return;
    }

    self.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                               object:activeCommands];
    
    for (char **devpath = g.gl_pathv; *devpath != NULL; devpath++) {
        LCSCommand *ctl = [LCSDiskInfoCommand commandWithDevicePath:
                                     [NSString stringWithCString:*devpath encoding:NSUTF8StringEncoding]];
        ctl.title = [NSString localizedStringWithFormat:@"Get information on device %s", *devpath];
        [activeCommands addCommand:ctl];
        [ctl start];
    }
    
    globfree(&g);
}

- (void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandCollection notificationNameAllCommandsEnteredState:LCSCommandStateFinished]
                                                  object:activeCommands];
    
    NSSortDescriptor *deviceIdSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"DeviceIdentifier"
                                                                            ascending:YES] autorelease];
    
    self.result = [[[activeCommands.commands valueForKeyPath:@"result"] allObjects]
                   sortedArrayUsingDescriptors:[NSArray arrayWithObject:deviceIdSortDescriptor]];
    self.state = LCSCommandStateFinished;
}

- (void)performStart
{
    self.state = LCSCommandStateRunning;
    [self startGatherInformation];
}

- (void)performCancel
{
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];    
}

@end
