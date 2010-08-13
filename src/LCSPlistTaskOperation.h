//
//  LCSPlistTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"
#import "LCSOperationParameter.h"


@interface LCSPlistTaskOperation : LCSTaskOperation {
    NSMutableData   *_outputData;
    id <LCSOperationInputParameter> extractKeyPath; /* NSString */
    id <LCSOperationInOutParameter> result; /* NSDictionary/NSArray */
}
@property(retain) id <LCSOperationInputParameter> extractKeyPath;
@property(retain) id <LCSOperationInOutParameter> result;
@end
