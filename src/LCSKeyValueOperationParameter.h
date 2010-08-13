//
//  LCSKeyValueOperationParameter.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationParameter.h"


@interface LCSKeyValueOperationInputParameter : NSObject <LCSOperationInputParameter> {
    id target;
    NSString* keyPath;
}
-(id)initWithTarget:(id)targetObject keyPath:(NSString*)targetKeyPath;
@end

@interface LCSKeyValueOperationInOutParameter : LCSKeyValueOperationInputParameter <LCSOperationInOutParameter>
@end

@interface LCSKeyValueOperationOutputParameter : LCSKeyValueOperationInOutParameter
@end
