//
//  LCSPropertyListSHA1Hash.m
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "LCSPropertyListSHA1Hash.h"


@implementation LCSPropertyListSHA1Hash
+(NSData*)sha1HashFromPropertyList:(id)propertyList
{
    NSString* outError;
    NSData* serializedPropertyList = [NSPropertyListSerialization dataFromPropertyList:propertyList
                                                                                format:NSPropertyListBinaryFormat_v1_0
                                                                      errorDescription:&outError];
    if (!serializedPropertyList) {
        // handle error
        return nil;
    }

    unsigned char md[CC_SHA1_DIGEST_LENGTH];
    unsigned char *md_result;

    md_result = CC_SHA1([serializedPropertyList bytes], [serializedPropertyList length], md);

    if (!md_result) {
        // handle error
        return nil;
    }
    NSData *hash = [NSData dataWithBytes:md length:sizeof(md)];
    return hash;
}
@end
