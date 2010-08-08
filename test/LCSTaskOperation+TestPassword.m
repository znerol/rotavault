//
//  LCSHdiUtilWithProgressOperation+TestPassword.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTaskOperation+TestPassword.h"


@implementation LCSTaskOperation (TestPassword)
- (void)injectTestPassword:(NSString*)password
{
    NSPipe *stdinPipe = [NSPipe pipe];

    [task setStandardInput:stdinPipe];
    [[stdinPipe fileHandleForWriting] writeData:[password dataUsingEncoding:NSUTF8StringEncoding]];
    [[stdinPipe fileHandleForWriting] closeFile];
}
@end
