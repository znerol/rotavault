//
//  NSScanner+AppleRAID.m
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSScanner+AppleRAID.h"


@implementation NSScanner (AppleRAID)
- (BOOL)scanAppleRAIDList:(NSArray**)intoArray
{
    BOOL ok = NO;
    
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];
    
    if([self scanString:@"No AppleRAID sets found\n" intoString:nil]) {
        ok = YES;
        if (intoArray != nil) {
            *intoArray = [NSArray array];
        }
    }
    
    if([self scanString:@"AppleRAID sets (" intoString:nil]) {
        int count = 0;
        ok = YES;
        ok &= [self scanInt:&count];
        ok &= [self scanString:@" found)\n" intoString:nil];
        if (!ok) goto finalizeAndReturn;
        
        NSMutableArray *entries = [NSMutableArray arrayWithCapacity:count];
        for(int i = 0; i<count; i++) {
            NSDictionary *entry;
            ok &= [self scanAppleRAIDEntry:&entry];
            if (!ok) goto finalizeAndReturn;
            
            [entries addObject:entry];
        }
        
        if (intoArray != nil) {
            *intoArray = [[entries copy] autorelease];
        }
    }
    
finalizeAndReturn:
    [self setCharactersToBeSkipped:saveSet];
    return ok;    
}

- (BOOL)scanAppleRAIDEntry:(NSDictionary**)intoDictionary
{
    BOOL ok = YES;
    
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];
    
    NSDictionary *properties;
    ok &= [self scanAppleRAIDEntrySeparator];
    ok &= [self scanAppleRAIDProperties:&properties];
    ok &= [self scanAppleRAIDMemberTableHeader];
    if (!ok) goto finalizeAndReturn;
    
    NSMutableArray *members = [NSMutableArray array];
    while(![self scanAppleRAIDEntrySeparator]) {
        if ([self isAtEnd]) {
            ok = NO;
            goto finalizeAndReturn;
        }
        
        NSDictionary *memberRow;
        ok &= [self scanAppleRAIDMemberRow:&memberRow];
        if (!ok) goto finalizeAndReturn;
        
        [members addObject:memberRow];
    }

    if (intoDictionary != nil) {
        NSMutableDictionary *entry = [[properties mutableCopy] autorelease];
        [entry setObject:members forKey:@"RAIDSetMembers"];
        *intoDictionary = [[entry copy] autorelease];
    }
    
finalizeAndReturn:
    [self setCharactersToBeSkipped:saveSet];
    return ok;
}

- (BOOL)scanAppleRAIDEntrySeparator
{
    BOOL ok = YES;
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];
    
    ok = [self scanString:@"===============================================================================\n"
               intoString:nil];
    
    [self setCharactersToBeSkipped:saveSet];
    return ok;
}

- (BOOL)scanAppleRAIDMemberTableHeader
{
    BOOL ok = YES;
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];
    
    [self setCharactersToBeSkipped:nil];
    ok &= [self scanString:@"-------------------------------------------------------------------------------\n"
                intoString:nil];
    ok &= [self scanString:@"#   Device Node       UUID                                   Status\n"
                intoString:nil];
    ok &= [self scanString:@"-------------------------------------------------------------------------------\n"
                intoString:nil];
    
    [self setCharactersToBeSkipped:saveSet];
    return ok;
}

- (BOOL)scanAppleRAIDProperties:(NSDictionary**)intoDictionary
{
    BOOL ok = YES;
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];
    
    NSString *name;
    ok &= [self scanString:@"Name:                 " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&name];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;
    
    NSString *uuid;
    ok &= [self scanString:@"Unique ID:            " intoString:nil];
    ok &= [self scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF-"]
                           intoString:&uuid];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;
    if (!ok) goto finalizeAndReturn;

    NSString *type;
    ok &= [self scanString:@"Type:                 " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&type];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;
    ok &= [[NSArray arrayWithObjects:@"Mirror", @"Stripe", @"Concat", nil] containsObject:type];
    if (!ok) goto finalizeAndReturn;
    
    NSString *status;
    ok &= [self scanString:@"Status:               " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&status];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;
    
    NSString *size;
    ok &= [self scanString:@"Size:                 " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&size];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;

    NSString *rebuild;
    ok &= [self scanString:@"Rebuild:              " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&rebuild];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;

    NSString *devid;
    ok &= [self scanString:@"Device Node:          " intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&devid];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;
    
    NSString *devnode = [NSString pathWithComponents:[NSArray arrayWithObjects:@"/", @"dev", devid, nil]];
    
    if (intoDictionary != nil) {
        *intoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                           name, @"RAIDSetName",
                           uuid, @"RAIDSetUUID",
                           type, @"RAIDSetLevelType",
                           status, @"RAIDSetStatus",
                           size, @"TotalSize",
                           rebuild, @"RebuildOption",
                           devid, @"DeviceIdentifier",
                           devnode,  @"DeviceNode",
                           nil];
    }
    
finalizeAndReturn:
    [self setCharactersToBeSkipped:saveSet];    
    return ok;
}

- (BOOL)scanAppleRAIDMemberRow:(NSDictionary**)intoDictionary
{
    BOOL ok = YES;
    NSCharacterSet *saveSet = [self charactersToBeSkipped];
    [self setCharactersToBeSkipped:nil];

    int index;
    NSString *devid;
    NSString *uuid;
    NSString *status;
    
    ok &= [self scanInt:&index];
    ok &= [self scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    ok &= [self scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&devid];
    ok &= [self scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    ok &= [self scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&uuid];
    ok &= [self scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:nil];
    ok &= [self scanUpToString:@"\n" intoString:&status];
    ok &= [self scanString:@"\n" intoString:nil];
    if (!ok) goto finalizeAndReturn;

    NSString *devnode = [NSString pathWithComponents:[NSArray arrayWithObjects:@"/", @"dev", devid, nil]];
    
    if (intoDictionary != nil) {
        *intoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:index +1], @"RAIDSliceNumber",
                           devnode, @"DeviceIdentifier",
                           devnode, @"DeviceNode",
                           uuid, @"RAIDMemberUUID",
                           status, @"RAIDSetStatus",
                           nil];
    }
    
finalizeAndReturn:
    [self setCharactersToBeSkipped:saveSet];    
    return ok;
}
@end
