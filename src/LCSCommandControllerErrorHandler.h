//
//  LCSCommandControllerErrorHandler.h
//  rotavault
//
//  Created by Lorenz Schori on 05.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol LCSCommandControllerErrorHandler <NSObject>
-(void)handleError:(NSError*)error fromController:(LCSCommandController*)controller;
@end
