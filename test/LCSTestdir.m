//
//  LCSTestdir.m
//  rotavault
//
//  Created by Lorenz Schori on 02.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestdir.h"
#import "LCSInitMacros.h"


@implementation LCSTestdir

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();

    NSTask  *mktemp = [[NSTask alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(mktemp);
    [mktemp setLaunchPath:@"/usr/bin/mktemp"];
    [mktemp setArguments:[NSArray arrayWithObjects:@"-d", @"/tmp/testdir_XXXXXXXX", nil]];

    NSPipe  *pipe = [[NSPipe alloc] init];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(pipe);
    [mktemp setStandardOutput:pipe];
    [mktemp launch];
    [mktemp waitUntilExit];

    NSData  *output = [[pipe fileHandleForReading] availableData];
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(output);
    tmpdir = [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
    tmpdir = [[tmpdir stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];

    [pipe release];
    [mktemp release];

    return self;
}

- (NSString*) path
{
    return tmpdir;
}

- (void) remove
{
    [[NSFileManager defaultManager] removeItemAtPath:tmpdir error:nil];
}

- (void) dealloc
{
    [tmpdir release];
    [super dealloc];
}

@end
