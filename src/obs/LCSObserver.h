//
//  LCSObserver.h
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    LCSObserverStateInit = 0,
    LCSObserverStateInstalled,
    LCSObserverStateRefreshing,
    LCSObserverStateFresh,
    LCSObserverStateStale,
    LCSObserverStateRemoved,
    LCSObserverStateCount
} LCSObserverState;

extern NSString *LCSObserverStateName[LCSObserverStateCount];


@interface LCSObserver : NSObject {
    LCSObserverState    state;
    id                  value;
    BOOL                autorefresh;
}

@property(assign) LCSObserverState  state;
@property(retain) id                value;
@property(assign) BOOL              autorefresh;

- (BOOL)validateNextState:(LCSObserverState)newState;
- (void)refreshInBackgroundAndNotify;
- (void)install;
- (void)remove;
@end

@interface LCSObserver (SubclassOverride)
/**
 * Install external callback handlers (like observers for NSDistributedNotifications or DiskArbitration)
 */
-(void)performInstall;

/**
 * Remove external callback handlers
 */
-(void)performRemove;

/**
 * Start refresh procedure in background
 */
-(void)performStartRefresh;
@end

@interface LCSObserver (NotificationHelpers)
+(NSString*)notificationNameStateLeft:(LCSObserverState)oldState;
+(NSString*)notificationNameStateTransfered:(LCSObserverState)oldState toState:(LCSObserverState)newState;
+(NSString*)notificationNameStateEntered:(LCSObserverState)newState;
+(NSString*)notificationNameStateChanged;
+(NSString*)notificationNameValueFresh;
@end

@interface LCSObserver (RunLoopHelpers)
-(void)waitUntil:(LCSObserverState)exitState;
@end
