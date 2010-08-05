//
//  LCSTestdir.h
//  rotavault
//
//  Created by Lorenz Schori on 02.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCSTestdir : NSObject {
    NSString *tmpdir;
}
- (LCSTestdir*) init;
- (NSString*) path;
@end
