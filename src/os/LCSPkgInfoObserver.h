//
//  LCSPkgInfoObserver.h
//  rotavault
//
//  Created by Lorenz Schori on 02.11.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSObserver.h"
#import "LCSCommand.h"


@interface LCSPkgInfoObserver : LCSObserver {
    NSString *pkgid;
    LCSCommand *pkgInfoCommand;
}
+ (LCSPkgInfoObserver*)observerWithPkgId:(NSString*)pkgid;
- (id)initWithPkgId:(NSString*)pkgid;
@end
