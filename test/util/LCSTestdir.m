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

    static const char template[] = "/tmp/testdir_XXXXXXXX";
    char *pathBuffer = malloc(sizeof(template));
    memcpy(pathBuffer, template, sizeof(template));
    pathBuffer[sizeof(template)-1]=0;
    
    if (mkdtemp(pathBuffer)) {
        tmpdir = [[NSString alloc] initWithCString:pathBuffer encoding:NSASCIIStringEncoding];
    }
    free(pathBuffer);
    
    LCSINIT_RELEASE_AND_RETURN_IF_NIL(tmpdir);
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
