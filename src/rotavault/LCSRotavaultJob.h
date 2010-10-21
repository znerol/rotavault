//
//  LCSRotavaultJob.h
//  rotavault
//
//  Created by Lorenz Schori on 21.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandController.h"


@interface LCSRotavaultJob : NSObject {
    LCSCommandController*   currentCommand;
    LCSCommandController*   backgroundCommand;
    
    AuthorizationRef        authorization;
    
    BOOL                    jobScheduled;
    BOOL                    jobRunning;
    
    NSString *label;
    BOOL runAsRoot;
    BOOL runAsRootEnabled;
    NSString *sourceDevice;
    BOOL sourceDeviceEnabled;
    NSInteger blockCopyMethodIndex;
    BOOL blockCopyMethodEnabled;
    NSString *targetDevice;
    BOOL targetDeviceEnabled;
    BOOL createImageEnabled;
    BOOL attachImageEnabled;
    NSDate *runDate;
    BOOL runDateEnabled;
    BOOL scheduleJobEnabled;
    BOOL startJobEnabled;
    NSString *statusMessage;
    BOOL removeJobEnabled;
}

@property(copy) NSString *label;

@property(assign) BOOL runAsRoot;
@property(assign) BOOL runAsRootEnabled;

@property(copy) NSString *sourceDevice;
@property(assign) BOOL sourceDeviceEnabled;

@property(assign) NSInteger blockCopyMethodIndex;
@property(assign) BOOL blockCopyMethodEnabled;

@property(copy) NSString *targetDevice;
@property(assign) BOOL targetDeviceEnabled;
@property(assign) BOOL createImageEnabled;
@property(assign) BOOL attachImageEnabled;

@property(copy) NSDate *runDate;
@property(assign) BOOL runDateEnabled;
@property(assign) BOOL scheduleJobEnabled;
@property(assign) BOOL startJobEnabled;

@property(copy) NSString *statusMessage;
@property(assign) BOOL removeJobEnabled;

- (id)initWithDataObject:(id)anObject keyPath:(NSString*)keyPath authorization:(AuthorizationRef)anAuth;
- (void)saveToDataObject:(id)anObject keyPath:(NSString*)keyPath;

- (void)scheduleJob;
- (void)startJob;
- (void)removeJob;
- (void)checkStatus;

- (void)updateControls;
@end
