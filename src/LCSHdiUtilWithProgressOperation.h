//
//  LCSHdiUtilWithProgressOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationBase.h"


@interface LCSHdiUtilWithProgressOperation : LCSTaskOperationBase
@end

@interface LCSCreateEncryptedImageOperation : LCSHdiUtilWithProgressOperation {
    id <LCSOperationInputParameter> path;       //NSString
    id <LCSOperationInputParameter> sectors;    //NSNumber
}
@property(retain) id <LCSOperationInputParameter> path;
@property(retain) id <LCSOperationInputParameter> sectors;
@end

