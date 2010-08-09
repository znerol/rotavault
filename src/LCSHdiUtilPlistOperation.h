//
//  LCSHdiUtilPlistOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSPlistTaskOperation.h"


@interface LCSHdiUtilPlistOperation : LCSPlistTaskOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments;
@end

@interface LCSHdiInfoOperation : LCSHdiUtilPlistOperation
-(id)init;
@end

@interface LCSAttachImageOperation : LCSHdiUtilPlistOperation
-(id)initWithPathToDiskImage:(NSString*)inPath;
@end

@interface LCSDetachImageOperation : LCSTaskOperation
-(id)initWithDevicePath:(NSString*)inPath;
@end
