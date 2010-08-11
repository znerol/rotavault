//
//  LCSDiskUtilOperation.m
//  rotavault
//
//  Created by Lorenz Schori on 08.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskUtilOperation.h"


@implementation LCSDiskUtilOperation
-(id)initWithCommand:(NSString*)command arguments:(NSArray*)arguments extractKeyPath:(NSString*)keyPath
{
    NSArray *args = [[NSArray arrayWithObjects:command, @"-plist", nil] arrayByAddingObjectsFromArray:arguments];
    self = [super initWithLaunchPath:@"/usr/sbin/diskutil" arguments:args extractKeyPath:keyPath];
    return self;
}
@end

@implementation LCSListDisksOperation
-(id)init
{
    self = [super initWithCommand:@"list" arguments:nil extractKeyPath:@"AllDisks"];
    return self;
}
@end

@implementation LCSInformationForDiskOperation
-(id)initWithDiskIdentifier:(NSString*)identifier
{
    self = [super initWithCommand:@"info" arguments:[NSArray arrayWithObject:identifier] extractKeyPath:nil];
    return self;
}
@end
