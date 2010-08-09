//
//  LCSPlistTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSTaskOperation.h"


@interface LCSPlistTaskOperation : LCSTaskOperation {
    NSMutableData   *_outputData;
}
@end
