//
//  LCSRotavaultSystemToolsInstaller.h
//  rotavault
//
//  Created by Lorenz Schori on 22.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSCommand.h"


@interface LCSRotavaultSystemTools : NSObject {
    LCSCommand* currentCommand;
    
    BOOL installed;
    BOOL upToDate;
    double installedVersion;
    double requiredVersion;
    BOOL autocheck;
}
@property(assign) BOOL installed;
@property(assign) BOOL upToDate;
@property(assign) double installedVersion;
@property(assign) double requiredVersion;
@property(assign) BOOL autocheck;

-(void)checkInstalledVersion;
@end
