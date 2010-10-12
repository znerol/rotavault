//
//  LCSLaunchctlUnload.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSExternalCommand.h"


@interface LCSLaunchctlUnloadCommand : LCSExternalCommand
-(id)initWithPath:(NSString*)plistPath;
+(LCSLaunchctlUnloadCommand*)commandWithPath:(NSString*)plistPath;
@end
