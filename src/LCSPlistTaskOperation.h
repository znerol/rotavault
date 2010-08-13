//
//  LCSPlistTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSPlistTaskOperation : LCSTaskOperation {
    NSMutableData   *_outputData;
    NSString        *extractKeyPath;
    NSDictionary    *result;
}
@property(retain) NSString *extractKeyPath;
@property(readonly) NSDictionary* result;
@end
