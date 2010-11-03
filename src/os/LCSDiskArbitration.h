//
//  LCSDiskArbitration.h
//  rotavault
//
//  Created by Lorenz Schori on 03.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DiskArbitration/DiskArbitration.h>


extern NSString* LCSDiskAppearedNotification;
extern NSString* LCSDiskDescriptionChangedNotification;
extern NSString* LCSDiskDisappearedNotification;

extern NSString* LCSDiskObjectKey;
extern NSString* LCSDiskChangedKeysKey;

@interface LCSDiskArbitration : NSObject {
    DASessionRef    session;
    NSRunLoop*      runloop;
    
    NSMutableSet*   disks;
}

@property(assign)           NSRunLoop* runloop;
@property(copy,readonly)    NSMutableSet* disks;

+ (LCSDiskArbitration*) sharedInstance;
@end
