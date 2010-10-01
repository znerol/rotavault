//
//  LCSTestdir.h
//  rotavault
//
//  Created by Lorenz Schori on 02.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LCSTestdir : NSObject {
    NSString *tmpdir;
}
- (NSString*) path;
- (void) remove;
@end
