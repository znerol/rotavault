//
//  LCSTestdir.m
//  rotavault
//
//  Created by Lorenz Schori on 02.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSTestdir.h"
#import "LCSInitMacros.h"

NSString* LCSTestdirTemplate = @"/tmp/testdir_XXXXXXXX";

@implementation LCSTestdir

+(void)setTemplate:(NSString*)newTemplate
{
    @synchronized(self) {
        if ([LCSTestdirTemplate isEqualToString:newTemplate]) {
            return;
        }
        
        [LCSTestdirTemplate release];
        LCSTestdirTemplate = [newTemplate retain];
    }
}

-(id)init
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    BOOL ok = NO;
    char *pathBuffer = nil;
    
    @synchronized(self) {
        size_t bufLen = [LCSTestdirTemplate length] + 1;
        pathBuffer = malloc(bufLen);
        ok = [LCSTestdirTemplate getCString:pathBuffer maxLength:bufLen encoding:NSUTF8StringEncoding];
    }
    assert(ok);
    
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
