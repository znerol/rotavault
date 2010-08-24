//
//  LCSSimpleOperationParameter.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationParameter.h"


@interface LCSSimpleOperationInputParameter : NSObject <LCSOperationInputParameter>
{
    id value;
}
-(id)initWithValue:(id)inValue;
@end

@interface LCSSimpleOperationOutputParameter : NSObject <LCSOperationOutputParameter>
{
    id* value;
}
-(id)initWithReturnValue:(id*)outValue;
@end
