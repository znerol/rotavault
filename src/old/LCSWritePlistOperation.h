//
//  LCSWritePlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 01.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSWritePlistOperation : LCSOperation {
    id <LCSOperationInputParameter> plist; //NSDictionary
    id <LCSOperationInOutParameter> plistPath; //NSString
}
@property(retain) id <LCSOperationInputParameter> plist;
@property(retain) id <LCSOperationInOutParameter> plistPath;
@end
