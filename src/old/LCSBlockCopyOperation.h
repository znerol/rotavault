//
//  LCSBlockCopyOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationBase.h"


@interface LCSBlockCopyOperation : LCSTaskOperationBase {
    id <LCSOperationInputParameter> source;
    id <LCSOperationInputParameter> target;
}
@property(retain) id <LCSOperationInputParameter> source;
@property(retain) id <LCSOperationInputParameter> target;
@end
