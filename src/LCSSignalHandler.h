//
//  LCSSignalHandler.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCSSignalHandler : NSObject {
    id delegate;
    NSPipe *sigpipe;
}
@property(assign) id delegate;
+(id)defaultSignalHandler;
-(void)addSignal:(int)sig;
@end
