//
//  LCSKeyValueOperationParameter.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationParameter.h"

@interface LCSKeyValueOperationParameterBase : NSObject
{
    id target;
    NSThread* targetThread;
    NSString* keyPath;    
}
-(id)initWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath;
@end

@interface LCSKeyValueOperationInputParameter : LCSKeyValueOperationParameterBase <LCSOperationInputParameter>
+(LCSKeyValueOperationInputParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath;
@end

@interface LCSKeyValueOperationInOutParameter : LCSKeyValueOperationParameterBase <LCSOperationInOutParameter>
+(LCSKeyValueOperationInOutParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath;
@end

@interface LCSKeyValueOperationOutputParameter : LCSKeyValueOperationParameterBase <LCSOperationOutputParameter>
+(LCSKeyValueOperationOutputParameter*)parameterWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath;
@end
