//
//  LCSTestObserver.h
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSObserver.h"


@interface LCSTestObserver : LCSObserver {
    NSTimeInterval      delay;
    LCSObserverState    finalState;
}
-(id)initWithDelay:(NSTimeInterval)aDelay finalState:(LCSObserverState)finalState;
+(LCSTestObserver*)observerWithDelay:(NSTimeInterval)aDelay finalState:(LCSObserverState)finalState;
@end
