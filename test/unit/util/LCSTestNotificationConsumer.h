//
//  LCSTestNotificationConsumer.h
//  rotavault
//
//  Created by Lorenz Schori on 24.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LCSTestNotificationConsumer
-(void)consumeNotification:(NSNotification*)ntf;
@end
