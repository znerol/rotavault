//
//  LCSPkgInfoCommand.h
//  rotavault
//
//  Created by Lorenz Schori on 22.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSPlistExternalCommand.h"


@interface LCSPkgInfoCommand : LCSPlistExternalCommand
+ (LCSPkgInfoCommand*)commandWithPkgId:(NSString*)pkgid;
- (id)initWithPkgId:(NSString*)pkgid;
@end
