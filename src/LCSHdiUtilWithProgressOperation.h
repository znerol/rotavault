//
//  LCSHdiUtilWithProgressOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSHdiUtilWithProgressOperation : LCSTaskOperation
@end

@interface LCSCreateEncryptedImageOperation : LCSHdiUtilWithProgressOperation {
    id <LCSOperationInputParameter> path;       //NSString
    id <LCSOperationInputParameter> sectors;    //NSNumber
}
@property(retain) id <LCSOperationInputParameter> path;
@property(assign) id <LCSOperationInputParameter> sectors;
@end

