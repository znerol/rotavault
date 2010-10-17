//
//  LCSSignalHandler.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LCSSignalHandlerDelegate
-(void)handleSignal:(NSNumber*)signal;
@end

@interface LCSSignalHandler : NSObject {
    id <LCSSignalHandlerDelegate> delegate;
    NSPipe *sigpipe;
}
@property(assign) id delegate;
+(id)defaultSignalHandler;
-(void)addSignal:(int)sig;
@end
