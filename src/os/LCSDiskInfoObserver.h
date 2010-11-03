//
//  LCSDiskInfoObserver.h
//  rotavault
//
//  Created by Lorenz Schori on 03.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSObserver.h"
#import "LCSCommandCollection.h"


@interface LCSDiskInfoObserver : LCSObserver {
    NSMutableSet        *dirty;
    NSMutableDictionary *commands;
}
+(LCSDiskInfoObserver*)observer;
@end
