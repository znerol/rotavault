//
//  LCSBlockCopyService.m
//  rotavault
//
//  Created by Lorenz Schori on 29.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSBlockCopyService.h"


@implementation LCSBlockCopyService

- (void)restoreFromSource:(NSString*)sourceDev toTarget:(NSString*)targetDev
{
    NSTask *asr = [[NSTask alloc] init];
    [asr setLaunchPath:@"/usr/sbin/asr"];

    NSArray *args = [NSArray arrayWithObjects:@"restore", @"--erase",
                     @"--source", sourceDev, @"--target", targetDev, nil];

    [asr setArguments:args];

    [asr launch];
    [asr waitUntilExit];
}

@end
