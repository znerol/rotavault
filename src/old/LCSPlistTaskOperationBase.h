//
//  LCSPlistTaskOperationBase.h
//  rotavault
//
//  Created by Lorenz Schori on 29.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationBase.h"


@interface LCSPlistTaskOperationBase : LCSTaskOperationBase {
    NSMutableData   *_outputData;
    id <LCSOperationInputParameter> extractKeyPath; /* NSString */
    id <LCSOperationOutputParameter> result; /* NSDictionary/NSArray */
}
@property(retain) id <LCSOperationInputParameter> extractKeyPath;
@property(retain) id <LCSOperationOutputParameter> result;
@end
