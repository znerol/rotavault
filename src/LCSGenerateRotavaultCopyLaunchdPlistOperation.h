//
//  LCSGenerateRotavaultCopyLaunchdPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSGenerateRotavaultCopyLaunchdPlistOperation : LCSOperation {
    id <LCSOperationInputParameter> runAtDate;  // NSDate*
    id <LCSOperationInputParameter> sourceInfo; // NSDictionary*
    id <LCSOperationInputParameter> targetInfo; // NSDictionary*
    id <LCSOperationOutputParameter> result;    // NSDictionary*
}
@property(retain) id <LCSOperationInputParameter> runAtDate;
@property(retain) id <LCSOperationInputParameter> sourceInfo;
@property(retain) id <LCSOperationInputParameter> targetInfo;
@property(retain) id <LCSOperationOutputParameter> result;
@end
