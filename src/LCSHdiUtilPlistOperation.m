//
//  LCSHdiUtilPlistOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSHdiUtilPlistOperation.h"


@implementation LCSHdiInfoOperation
-(void)taskBuildArguments
{
    self.launchPath = @"/usr/bin/hdiutil";
    self.arguments = [NSArray arrayWithObjects:@"info", @"-plist", nil];
}
@end

@implementation LCSAttachImageOperation

@synthesize path;

-(void)taskBuildArguments
{
    self.launchPath = @"/usr/bin/hdiutil";
    self.arguments = [NSArray arrayWithObjects:@"attach", path, @"-plist", @"-nomount", nil];
}
@end

@implementation LCSDetachImageOperation

@synthesize path;

-(void)taskBuildArguments
{
    self.launchPath = @"/usr/bin/hdiutil";
    self.arguments = [NSArray arrayWithObjects:@"detach", path, nil];
}
@end
