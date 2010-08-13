//
//  LCSOperationParameterMarker.h
//  rotavault
//
//  Created by Lorenz Schori on 13.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSOperationParameter.h"


@interface LCSOperationRequiredInputParameterMarker : NSObject <LCSOperationInputParameter>
@end

@interface LCSOperationRequiredInOutParameterMarker : NSObject <LCSOperationInOutParameter>
@end

@interface LCSOperationRequiredOutputParameterMarker : NSObject <LCSOperationOutputParameter>
@end

@interface LCSOperationOptionalInputParameterMarker : NSObject <LCSOperationInputParameter>
-(id)initWithDefaultValue:(id)defaultValue;
@end

@interface LCSOperationOptionalInOutParameterMarker : NSObject <LCSOperationInOutParameter>
-(id)initWithDefaultValue:(id)defaultValue;
@end

@interface LCSOperationOptionalOutputParameterMarker : NSObject <LCSOperationOutputParameter>
@end
