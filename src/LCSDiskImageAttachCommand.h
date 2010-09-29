//
//  LCSDiskImageAttachCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistExternalCommand.h"


@interface LCSDiskImageAttachCommand : LCSPlistExternalCommand
-(id)initWithImagePath:(NSString*)imagePath;
-(LCSDiskImageAttachCommand*)commandWithImagePath:(NSString*)imagePath;
@end
