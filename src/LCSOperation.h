//
//  LCSOperation.h
//  rotavault
//
//  Created by Lorenz Schori on 11.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCSTaskOperationError.h"


@interface LCSOperation : NSOperation {
    NSString    *name;
    id          delegate;

    id          environmentContext;
    id          parameterContext;
    id          resultContext;

    NSString    *environmentKeyPath;
    NSString    *parameterKeyPath;
    NSString    *resultKeyPath;
}

@property(retain) NSString *name;
@property(assign) id delegate;

@property(retain) id environmentContext;
@property(retain) id parameterContext;
@property(retain) id resultContext;

@property(retain) NSString *environmentKeyPath;
@property(retain) NSString *parameterKeyPath;
@property(retain) NSString *resultKeyPath;

-(void)handleError:(NSError*)error;
-(void)handleResult:(id)result;
-(void)updateProgress:(float)progress;
-(void)operationStarted;
-(void)operationFinished;

@end
