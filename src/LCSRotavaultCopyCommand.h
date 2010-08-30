//
//  LCSRotavaultCopyCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSDiskUtilOperation.h"
#import "LCSCommand.h"


@interface LCSRotavaultCopyCommand : LCSCommand {
    NSDictionary        *sourceInfo;
    NSDictionary        *targetInfo;
    LCSMountOperation   *sourceRemountOperation;    
}
-(id)initWithSourceDevice:(NSString*)sourceDevice
              sourceCheck:(NSString*)sourceChecksum
             targetDevice:(NSString*)targetDevice
           targetChecksum:(NSString*)targetChecksum;
@end
