//
//  LCSHdiUtilPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilPlistOperation.h"


@implementation LCSHdiUtilPlistOperation

-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments
{
    NSArray *args = [[NSArray arrayWithObjects:command, @"-plist", nil] arrayByAddingObjectsFromArray:arguments];
    self = [super initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    return self;
}
@end

@implementation LCSHdiInfoOperation
-(id)init
{
    self = [super initWithCommand:@"info" arguments:nil];
    return self;
}
@end

@implementation LCSHdiInfoForImageOperation
-(id)initWithPathToDiskImage:(NSString*)inPath
{
    self = [super init];
    imagePath = [inPath retain];
    return self;
}

-(NSDictionary*)result
{
    NSDictionary* resultFromSuper = [super result];

    NSArray* images = [resultFromSuper objectForKey:@"images"];
    if (images != nil) {
        for (NSDictionary* info in images) {
            if ([imagePath isEqualToString: [info objectForKey:@"image-path"]]) {
                return info;
            }
        }
    }

    // FIXME: report an error with appropriate message
    return nil;
}

-(void)dealloc
{
    [imagePath release];
    [super dealloc];
}
@end

@implementation LCSHdiDeviceForImageOperation
-(id)initWithPathToDiskImage:(NSString*)inPath
{
    self = [super initWithPathToDiskImage:inPath];
    return self;
}

-(NSArray*)result
{
    NSDictionary* resultFromSuper = [super result];
    
    if (resultFromSuper == nil) {
        // FIXME: report an error with appropriate message        
        return nil;
    }
    return [resultFromSuper valueForKeyPath:@"system-entities.dev-entry"];
}
@end

@implementation LCSAttachImageOperation
-(id)initWithPathToDiskImage:(NSString*)inPath
{
    NSArray *args = [NSArray arrayWithObjects:inPath, @"-nomount", nil];
    self = [super initWithCommand:@"attach" arguments:args];
    return self;
}
@end

@implementation LCSDetachImageOperation
-(id)initWithDevicePath:(NSString*)inPath
{
    NSArray *args = [NSArray arrayWithObjects:@"detach", inPath, nil];
    self = [super initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    return self;
}
@end
