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
