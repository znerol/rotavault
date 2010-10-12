//
//  LCSDiskImageAttachCommand.m
//  rotavault
//
//  Created by Lorenz Schori on 29.09.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSDiskImageAttachCommand.h"
#import "LCSInitMacros.h"


@implementation LCSDiskImageAttachCommand
-(id)initWithImagePath:(NSString *)imagePath
{
    LCSINIT_SUPER_OR_RETURN_NIL();
    
    [task setLaunchPath:@"/usr/bin/hdiutil"];
    [task setArguments:[NSArray arrayWithObjects:@"attach", imagePath, @"-plist", @"-nomount", nil]];
    
    return self;
}

+(LCSDiskImageAttachCommand*)commandWithImagePath:(NSString *)imagePath
{
    return [[[LCSDiskImageAttachCommand alloc] initWithImagePath:imagePath] autorelease];
}
@end
