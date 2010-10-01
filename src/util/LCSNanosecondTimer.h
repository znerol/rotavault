//
//  LCSNanosecondTimer.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCSNanosecondTimer : NSObject {
    uint64_t        reference;
}

-(void)setReferenceTime;
-(long double)nanosecondsSinceReferenceTime;
@end
