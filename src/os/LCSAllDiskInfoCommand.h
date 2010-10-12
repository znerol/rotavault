//
//  LCSRotavaultAllDiskInformationCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 11.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSBatchCommand.h"


@interface LCSAllDiskInfoCommand : LCSBatchCommand
+ (LCSAllDiskInfoCommand*)command;
@end
