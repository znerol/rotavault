//
//  LCSRotavaultScheduleInstallOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationQueueOperation.h"

#import "LCSGenerateRotavaultCopyLaunchdPlistOperation.h"
#import "LCSBlockCopyValidateDiskInfoOperation.h"
#import "LCSWritePlistOperation.h"
#import "LCSDiskUtilOperation.h"
#import "LCSLaunchctlOperation.h"


@interface LCSRotavaultScheduleInstallOperation : LCSOperationQueueOperation
{
    id <LCSOperationInputParameter> sourceDevice;
    id <LCSOperationInputParameter> targetDevice;
    id <LCSOperationInputParameter> runAtDate;
    
    NSDictionary    *sourceInfo;
    NSDictionary    *targetInfo;
    NSDictionary    *bootdiskInfo;
    NSDictionary    *launchdPlist;
    NSString        *plistPath;
    
    LCSInformationForDiskOperation                  *sourceInfoOperation;
    LCSInformationForDiskOperation                  *targetInfoOperation;
    LCSInformationForDiskOperation                  *bootdiskInfoOperation;
    LCSBlockCopyValidateDiskInfoOperation           *validateDiskInfoOperation;
    LCSGenerateRotavaultCopyLaunchdPlistOperation   *plistGenOperation;
    LCSWritePlistOperation                          *plistInstallOperation;
    LCSLaunchctlRemoveOperation                     *launchctlRemoveOperation;
    LCSLaunchctlLoadOperation                       *launchctlLoadOperation;
}
@property(retain) id <LCSOperationInputParameter> sourceDevice;
@property(retain) id <LCSOperationInputParameter> targetDevice;
@property(retain) id <LCSOperationInputParameter> runAtDate;
@end
