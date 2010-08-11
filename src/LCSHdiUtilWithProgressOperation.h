//
//  LCSHdiUtilWithProgressOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperation.h"


@interface LCSHdiUtilWithProgressOperation : LCSTaskOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments;
@end

@interface LCSCreateEncryptedImageOperation : LCSHdiUtilWithProgressOperation
-(id)initWithPath:(NSString*)inPath sectors:(NSInteger)sectors;
@end

