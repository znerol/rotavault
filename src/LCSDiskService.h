//
//  LCSDiskService.h
//  rotavault
//
//  Created by Lorenz Schori on 21.07.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSDiskService : NSObject {
}
- (NSArray*) listDisks;
- (NSDictionary*) diskInfo:(NSString*)identifier;
- (NSArray *)listVolumes;
@end
