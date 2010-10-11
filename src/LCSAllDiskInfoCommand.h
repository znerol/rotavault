//
//  LCSRotavaultAllDiskInformationCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 11.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSCommandControllerCollection.h"


@interface LCSAllDiskInfoCommand : NSObject <LCSCommand> {
    LCSCommandControllerCollection* activeControllers;
}
+ (LCSAllDiskInfoCommand*)command;
@end
