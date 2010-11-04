//
//  LCSRotavaultSystemEnvironment.h
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSObserver.h"


extern NSString* LCSRotavaultSystemEnvironmentRefreshed;

@interface LCSRotavaultSystemEnvironmentObserver : NSObject {
    NSMutableDictionary *registry;
    
    LCSObserver*    systoolsInfoObserver;
    LCSObserver*    diskInfoObserver;
    LCSObserver*    appleraidObserver;
}
@property(readonly) NSMutableDictionary *registry;

+ (LCSRotavaultSystemEnvironmentObserver*)defaultSystemEnvironmentObserver;
- (void)refreshInBackgroundAndNotify;
@end
