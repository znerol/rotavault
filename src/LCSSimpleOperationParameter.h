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
+(LCSSimpleOperationInputParameter*)parameterWithValue:(id)newValue;
-(id)initWithValue:(id)newValue;
@end

@interface LCSSimpleOperationOutputParameter : NSObject <LCSOperationOutputParameter>
{
    id* value;
}
+(LCSSimpleOperationOutputParameter*)parameterWithReturnValue:(id*)returnPointer;
-(id)initWithReturnValue:(id*)returnPointer;
@end
