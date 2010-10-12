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
#import "LCSCommandRunner.h"

@interface LCSAllDiskInfoCommand (PrivateMethods)
-(void)startGatherInformation;
-(void)completeGatherInformation:(NSNotification*)ntf;
@end

@implementation LCSAllDiskInfoCommand

+ (LCSAllDiskInfoCommand*)command
{
    return [[[LCSAllDiskInfoCommand alloc] init] autorelease];
}

- (void)startGatherInformation
{
    NSParameterAssert([activeControllers.controllers count] == 0);
    
    glob_t g;
    int err = glob("/dev/disk*", GLOB_NOSORT, NULL, &g);
    
    /* iterate thru disks */
    if (err != 0) {
        NSString *reason = LCSErrorLocalizedFailureReasonFromErrno(errno);
        NSError *error = LCSERROR_METHOD(NSPOSIXErrorDomain, errno,
                                         LCSERROR_LOCALIZED_DESCRIPTION(@"Unable to get list of disk device nodes: %@", reason),
                                         LCSERROR_LOCALIZED_DESCRIPTION(reason));
        globfree(&g);
        [self handleError:error];
        return;
    }

    controller.progressMessage = [NSString localizedStringWithFormat:@"Gathering information"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeGatherInformation:)
                                                 name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                               object:activeControllers];
    
    for (char **devpath = g.gl_pathv; *devpath != NULL; devpath++) {
        LCSCommandController *ctl = [LCSCommandController controllerWithCommand:
                                     [LCSDiskInfoCommand commandWithDevicePath:
                                      [NSString stringWithCString:*devpath encoding:NSUTF8StringEncoding]]];
        ctl.title = [NSString localizedStringWithFormat:@"Get information on device %s", *devpath];
        [activeControllers addController:ctl];
        [ctl start];
    }
    
    globfree(&g);
}

- (void)completeGatherInformation:(NSNotification*)ntf
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[LCSCommandControllerCollection notificationNameAllControllersEnteredState:LCSCommandStateFinished]
                                                  object:activeControllers];
    
    NSArray *entries = [[activeControllers valueForKeyPath:@"controllers.result"] allObjects];
    NSArray *devnodes = [entries valueForKey:@"DeviceNode"];
    
    controller.result = [NSDictionary dictionaryWithObjects:entries forKeys:devnodes];
    controller.state = LCSCommandStateFinished;
}

- (void)start
{
    controller.state = LCSCommandStateRunning;
    [self startGatherInformation];
}

- (void)cancel
{
    [self handleError:LCSERROR_METHOD(NSCocoaErrorDomain, NSUserCancelledError)];    
}

@end
