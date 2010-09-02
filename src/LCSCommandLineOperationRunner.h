//
//  LCSCommandLineOperationRunner.h
//  rotavault
//
//  Created by Lorenz Schori on 02.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperation.h"


@interface LCSCommandLineOperationRunner : NSObject {
    LCSOperation*   _operation;
    NSError*        _firstError;
}

+(NSError*)runOperation:(LCSOperation*)operation;

-(id)initWithOperation:(LCSOperation*)operation;
-(NSError*)run;
@end
