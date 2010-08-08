//
//  LCSHdiUtilInfoOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSPlistTaskOperation.h"


@interface LCSHdiUtilInfoOperation : LCSPlistTaskOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments;
@end

@interface LCSHdiInfoOperation : LCSHdiUtilInfoOperation
-(id)init;
@end


@interface LCSHdiInfoForImageOperation: LCSHdiInfoOperation {
    NSString *imagePath;
}

-(id)initWithPathToDiskImage:(NSString*)inPath;
@end

@interface LCSHdiDeviceForImageOperation : LCSHdiInfoForImageOperation
@property(readonly) NSArray* result;
-(id)initWithPathToDiskImage:(NSString*)inPath;
@end
