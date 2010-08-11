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
    NSString        *resultKeyPath;
}
-(id)initWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments resultKeyPath:(NSString*)keyPath;
@end
