//
//  LCSRotavaultFreshSystemEnvironmentCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 01.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSRotavaultSystemEnvironmentObserver.h"


@interface LCSRotavaultFreshSystemEnvironmentCommand : LCSCommand {
    LCSRotavaultSystemEnvironmentObserver* observer;
}

+ (LCSRotavaultFreshSystemEnvironmentCommand*)commandWithSystemEnvironmentObserver:(LCSRotavaultSystemEnvironmentObserver*)newObserver;
+ (LCSRotavaultFreshSystemEnvironmentCommand*)commandWithDefaultSystemEnvironmentObserver;
- (id)initWithSystemEnvironmentObserver:(LCSRotavaultSystemEnvironmentObserver*)newObserver;
- (id)initWithDefaultSystemEnvironmentObserver;
@end
