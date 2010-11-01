//
//  LCSRotavaultSystemEnvironment.h
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


extern NSString* LCSRotavaultSystemEnvironmentRefreshed;

@interface LCSRotavaultSystemEnvironmentObserver : NSObject {
    NSMutableDictionary *registry;
    
    LCSCommand* systoolsInfoCommand;
    BOOL        systoolsInfoFresh;
    double      systoolsInstalledVersion;
    BOOL        systoolsInstalled;
    
    BOOL        watching;
}
@property(readonly) NSMutableDictionary *registry;

- (void)watch;
- (void)unwatch;
- (void)refreshInBackgroundAndNotify;
@end
