//
//  LCSInstallRotavaultCopyLaunchdPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSInstallRotavaultCopyLaunchdPlistOperation : LCSOperation {
    id <LCSOperationInputParameter> launchdPlist; //NSDictionary
    id <LCSOperationInputParameter> installPath; //NSString
}
@property(retain) id <LCSOperationInputParameter> launchdPlist;
@property(retain) id <LCSOperationInputParameter> installPath;
@end
