//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"


@implementation LCSDiskUtilOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments
{
    NSArray *args = [NSArray arrayWithObjects:command, @"-plist", nil];
    if(args) {
        args = [args arrayByAddingObjectsFromArray:arguments];
    }
    self = [super initWithLaunchPath:@"/usr/sbin/diskutil" arguments:args];
    return self;
}
@end

@implementation LCSListDisksOperation
-(id)init
{
    self = [super initWithCommand:@"list" arguments:nil];
    return self;
}

-(NSArray*) result
{
    NSDictionary* resultFromSuper = [super result];
    return [resultFromSuper objectForKey:@"AllDisks"];
}
@end

@implementation LCSInformationForDiskOperation
-(id)initWithDiskIdentifier:(NSString*)identifier
{
    self = [super initWithCommand:@"info" arguments:[NSArray arrayWithObject:identifier]];
    return self;
}

@end
