//
//  LCSTestRamdisk.h
//  rotavault
//
//  Created by Lorenz Schori on 13.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCSTestRamdisk : NSObject {
    NSString* devnode;
    NSString* mountpoint;
}
@property(readonly) NSString* devnode;
@property(readonly) NSString* mountpoint;
-(id) initWithBlocks:(int)blocks;
-(void) remove;
@end
