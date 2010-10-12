//
//  NSScanner+AppleRAID.h
//  rotavault
//
//  Created by Lorenz Schori on 12.10.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSScanner (AppleRAID)
- (BOOL)scanAppleRAIDList:(NSArray**)intoArray;
- (BOOL)scanAppleRAIDEntry:(NSDictionary**)intoDictionary;
- (BOOL)scanAppleRAIDEntrySeparator;
- (BOOL)scanAppleRAIDMemberTableHeader;
- (BOOL)scanAppleRAIDProperties:(NSDictionary**)intoDictionary;
- (BOOL)scanAppleRAIDMemberRow:(NSDictionary**)intoDictionary;
@end
