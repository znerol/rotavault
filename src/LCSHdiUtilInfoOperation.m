//
//  LCSHdiUtilInfoOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilInfoOperation.h"


@implementation LCSHdiUtilInfoOperation

-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments
{
    NSArray *args = [NSArray arrayWithObjects:command, @"-plist", nil];
    if(args) {
        args = [args arrayByAddingObjectsFromArray:arguments];
    }
    self = [super initWithLaunchPath:@"/usr/bin/hdiutil" arguments:args];
    return self;
}

-(BOOL)hasBrokenStdoutHandling {
    return YES;
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
    
    NSArray* sysentities = [resultFromSuper objectForKey:@"system-entities"];
    if (sysentities == nil) {
        // FIXME: report an error with appropriate message
        return nil;
    }
    
    NSMutableArray* deventries =
    [NSMutableArray arrayWithCapacity:[sysentities count]];
    for (NSDictionary *item in sysentities) {
        [deventries addObject:[item objectForKey:@"dev-entry"]];
    }

    return [NSArray arrayWithArray:deventries];
}
@end
