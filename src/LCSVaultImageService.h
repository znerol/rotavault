//
//  LCSVaultImageService.h
//  rotavault
//
//  Created by Lorenz Schori on 22.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCSPassphraseReader.h"
#import "LCSOutputHandler.h"
#import "LCSStatusReporter.h"


@interface LCSVaultImageService : NSObject {
@private
    id <LCSPassphraseReader>    passphraseReader;
    id <LCSOutputHandler>   progressIndicator;
    id <LCSStatusReporter>  statusReporter;
}

- (LCSVaultImageService*)
    initWithPassphraseReader:(id <LCSPassphraseReader>)pwread
    progressIndicator:(id <LCSOutputHandler>)progind
    statusReporter:(id <LCSStatusReporter>)reporter;

/**
 * Create a new image at the specified path with the given number of sectors.
 */
- (void) createAtPath:(NSString *)path sectors:(NSInteger)sectors;

/**
 * Attach existing image without mounting the contained volumes
 */
- (void) attachImage:(NSString*)image;

- (NSDictionary*)info;

/**
 * Return a dictionary with information about an attached image
 */
- (NSDictionary*) infoForImage:(NSString*)path;

/**
 * Return a list of BSD device paths (/dev/diskX[sY]) for this image.
 */
- (NSArray*) devicesForImage:(NSString*)imagePath;

@end
