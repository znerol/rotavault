//
//  LCSRotavaultSystemEnvironment.h
//  rotavault
//
//  Created by Lorenz Schori on 30.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSRotavaultSystemEnvironmentObserver : NSObject {
    NSMutableDictionary *registry;
    
    LCSCommand* pkgInfoCommand;
    BOOL        pkgInfoPresent;
    double      installedVersion;
    BOOL        installed;
    BOOL        upToDate;
    
    BOOL        autocheck;
}
@property(readonly) NSMutableDictionary *registry;
@property(assign) BOOL autocheck;

-(void)checkInstalledVersion;
@end
