//
//  LCSBlockCopyOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 05.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSBlockCopyOperation : LCSTaskOperation {
    NSString* source;
    NSString* target;
}
@property(retain) NSString* source;
@property(retain) NSString* target;
@end
