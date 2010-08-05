//
//  LCSPlistTaskOutputHandler.h
//  rotavault
//
//  Created by Lorenz Schori on 03.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSPlistTaskOutputHandler : NSObject {
    NSTask*         target;
    NSPipe*         pipe;
    NSMutableData*  buffer;
}

- (LCSPlistTaskOutputHandler*) initWithTarget:(NSTask*) targetTask;
- (NSDictionary*) results;

+ (NSDictionary*) resultsFromTerminatedTaskWithLaunchPath:(NSString *)path
                                                arguments:(NSArray *)arguments;
@end
