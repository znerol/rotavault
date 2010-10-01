//
//  LCSPropertyListSHA1Hash.h
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface LCSPropertyListSHA1Hash : NSObject
+(NSData*)sha1HashFromPropertyList:(id)propertyList;
@end
