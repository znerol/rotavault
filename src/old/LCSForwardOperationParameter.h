//
//  LCSForwardOperationParameter.h
//  rotavault
//
//  Created by Lorenz Schori on 14.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationParameter.h"


@interface LCSForwardOperationInputParameter : NSObject <LCSOperationInputParameter>
{
    id <LCSOperationInputParameter> *ptr;
}
+(LCSForwardOperationInputParameter*)parameterWithParameterPointer:(id <LCSOperationInputParameter> *)paramPointer;
-(id)initWithInputParameterPointer:(id <LCSOperationInputParameter> *)paramPointer;
@end



@interface LCSForwardOperationInOutParameter : NSObject <LCSOperationInOutParameter>
{
    id <LCSOperationInOutParameter> *ptr;
}
+(LCSForwardOperationInOutParameter*)parameterWithParameterPointer:(id <LCSOperationInOutParameter> *)paramPointer;
-(id)initWithInOutParameterPointer:(id <LCSOperationInOutParameter> *)paramPointer;
@end



@interface LCSForwardOperationOutputParameter : NSObject <LCSOperationOutputParameter>
{
    id <LCSOperationOutputParameter> *ptr;
}
+(LCSForwardOperationOutputParameter*)parameterWithParameterPointer:(id <LCSOperationOutputParameter> *)paramPointer;
-(id)initWithOutputParameterPointer:(id <LCSOperationOutputParameter> *)paramPointer;
@end
