//
//  LCSVaultImageService.m
//  rotavault
//
//  Created by Lorenz Schori on 22.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSVaultImageService.h"


@implementation LCSVaultImageService

/**
 *
 */
- (LCSVaultImageService*)
    initWithPassphraseReader:(id <LCSPassphraseReader>)pwread
           progressIndicator:(id <LCSOutputHandler>)progind
              statusReporter:(id <LCSStatusReporter>)reporter
{
    self = [super init];
    passphraseReader = pwread;
    progressIndicator = progind;
    statusReporter = reporter;
    return self;
}

/**
 * Create a new image at the specified path with the given number of sectors.
 */
- (void) createAtPath:(NSString *)path sectors:(NSInteger)sectors
{
    NSTask* hdiutil = [[NSTask alloc] init];
    [hdiutil setLaunchPath:@"/usr/bin/hdiutil"];

    NSArray *args = [NSArray arrayWithObjects: @"create",
                     @"-sectors",
                     [[NSNumber numberWithInt:sectors] stringValue],
                     path,
                     @"-type", @"UDIF",
                     @"-layout", @"NONE",
                     @"-encryption", @"AES-256", nil];

    [hdiutil setArguments:args];

    if (passphraseReader != nil)
        [passphraseReader prepareTask:hdiutil];

    if (progressIndicator != nil)
        [progressIndicator prepareTask:hdiutil];
    
    if (statusReporter != nil)
        [statusReporter prepareTask:hdiutil];
    
    [hdiutil launch];

    /* poll the runLoop in defaultMode until task completes */ 
    [hdiutil waitUntilExit];
    
    [hdiutil autorelease];
}

/**
 * Attach existing image without mounting the contained volumes
 */
- (void) attachImage:(NSString*)path
{
    NSTask* hdiutil = [[NSTask alloc] init];
    [hdiutil setLaunchPath:@"/usr/bin/hdiutil"];

    NSArray *args = [NSArray arrayWithObjects: @"attach",
                     @"-nomount", path, nil];

    [hdiutil setArguments:args];

    if (passphraseReader != nil)
        [passphraseReader prepareTask:hdiutil];

    if (progressIndicator != nil)
        [progressIndicator prepareTask:hdiutil];

    if (statusReporter != nil)
        [statusReporter prepareTask:hdiutil];

    [hdiutil launch];

    /* poll the runLoop in defaultMode until task completes */ 
    [hdiutil waitUntilExit];
    [hdiutil autorelease];
}

- (NSDictionary*)info
{
    NSTask* hdiutil = [[NSTask alloc] init];
    [hdiutil setLaunchPath:@"/usr/bin/hdiutil"];

    NSArray *args = [NSArray arrayWithObjects: @"info", @"-plist", nil];
    [hdiutil setArguments:args];
    
    NSPipe *stdoutPipe = [NSPipe pipe];
    [hdiutil setStandardOutput:stdoutPipe];
    [hdiutil launch];
    [hdiutil waitUntilExit];
    [hdiutil autorelease];
    
    NSData *data = [[stdoutPipe fileHandleForReading] availableData];
    NSPropertyListFormat format;
    NSString *error = [NSString string];
    NSDictionary *result =
    (NSDictionary*)[NSPropertyListSerialization
                    propertyListFromData:data
                    mutabilityOption:NSPropertyListImmutable
                    format:&format errorDescription:&error];
    return result;
}

/**
 * Return a dictionary with information about an attached image
 */
- (NSDictionary*) infoForImage:(NSString*)path
{
    NSDictionary* info = [self info];

    NSArray* images = [info objectForKey:@"images"];
    if (images == nil)
        return nil;

    for (NSDictionary* info in images) {
        if ([path isEqualToString: [info objectForKey:@"image-path"]]) {
            return info;
        }
    }
    return nil;
}

/**
 * Return a list of BSD device paths (/dev/diskX[sY]) for this image.
 */
- (NSArray*) devicesForImage:(NSString*)imagePath
{
    NSDictionary* info = [self infoForImage:imagePath];
    if (info == nil)
        return nil;

    NSArray* sysentities = [info objectForKey:@"system-entities"];
    if (sysentities == nil)
        return nil;

    NSMutableArray* result =
        [NSMutableArray arrayWithCapacity:[sysentities count]];
    for (NSDictionary *item in sysentities) {
        [result addObject:[item objectForKey:@"dev-entry"]];
    }

    return [NSArray arrayWithArray:result];
}

@end
