//
//  NSData+Hex.h
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (Hex)
-(NSString*) stringWithHexBytes;
+(NSData*) dataFromHexString:(NSString*)hexString;
@end
