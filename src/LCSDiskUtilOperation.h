//
//  LCSDiskUtilOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistTaskOperation.h"


@interface LCSDiskUtilOperation : LCSPlistTaskOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments extractKeyPath:(NSString*)keyPath;
@end

@interface LCSListDisksOperation : LCSDiskUtilOperation
-(id)init;
@end

@interface LCSInformationForDiskOperation : LCSDiskUtilOperation
-(id)initWithDiskIdentifier:(NSString*)identifier;
@end
