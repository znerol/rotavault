//
//  LCSTestdir.m
//  rotavault
//
//  Created by Lorenz Schori on 02.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestdir.h"
#import "LCSPlistTaskOutputHandler.h"


@implementation LCSTestdir

- (LCSTestdir*) init
{
    self = [super init];

    NSTask  *mktemp = [[NSTask alloc] init];
    [mktemp setLaunchPath:@"/usr/bin/mktemp"];
    [mktemp setArguments:[NSArray arrayWithObjects:@"-d", @"/tmp/testdir_XXXXXXXX", nil]];

    NSPipe  *pipe = [[NSPipe alloc] init];
    [mktemp setStandardOutput:pipe];
    [mktemp launch];
    [mktemp waitUntilExit];
    
    NSData  *output = [[pipe fileHandleForReading] availableData];
    tmpdir = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    tmpdir = [tmpdir stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [pipe release];
    [mktemp release];

    return self;
}

- (NSString*) path
{
    return tmpdir;
}

- (void) dealloc
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    [fm removeItemAtPath:tmpdir error:nil];
    [tmpdir release];
    [fm release];
    [super dealloc];
}

@end
