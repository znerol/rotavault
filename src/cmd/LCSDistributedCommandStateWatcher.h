//
//  LCSDistributedCommandStateWatcher.h
//  rotavault
//
//  Created by Lorenz Schori on 20.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommandController.h"


@interface LCSDistributedCommandStateWatcher : LCSCommandController {
    NSString *label;
}
+ (LCSDistributedCommandStateWatcher*)commandWithLabel:(NSString*)senderLabel;
- (id)initWithLabel:(NSString*)senderLabel;
@end
