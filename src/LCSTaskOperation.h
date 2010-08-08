//
//  LCSTaskOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 06.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSTaskOperationError.h"


@interface LCSTaskOperation : NSOperation {
    NSTask      *task;
    NSString    *path;
    float       progress;
    NSError     *error;
    NSData      *output;
}

-(id)initWithLaunchPath:(NSString*)path arguments:(NSArray*)arguments;
-(BOOL)parseOutput:(NSData*)data isAtEnd:(BOOL)atEnd error:(NSError**)outError;

@property(readonly) BOOL hasProgress;
@property(readonly) NSString *path;
@property(readonly) float progress;
@property(readonly) NSError* error;
@property(readonly) NSData* output;

@end
