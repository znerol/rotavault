//
//  NSData+Hex.m
//  rotavault
//
//  Created by Lorenz Schori on 30.08.10.
//  Copyright 2010 znerol.ch. All rights reserved.
//

#import "NSData+Hex.h"


@implementation NSData (Hex)
-(NSString*) stringWithHexBytes {
	NSMutableString *result = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *data = [self bytes];

	for (unsigned int i = 0; i < [self length]; i++) {
		[result appendFormat:@"%02X", data[i]];
    }

	return [[result copy] autorelease];
}

+(NSData*) dataFromHexString:(NSString*)hexString {
    /* True if we currently operate on the low nibble of the hex char */
    BOOL atLowNibble = [hexString length] % 2 != 0;
    unsigned char byte = 0;

    NSMutableData* result = [NSMutableData dataWithCapacity:[hexString length] / 2];
    for (NSUInteger i = 0; i < [hexString length]; i++) {
        unsigned char nibble = [hexString characterAtIndex:i];

        switch (nibble & 0xF0) {
            case 0x30:
                /* digits 0-7 at ascii 0x30-0x37 */
                nibble &= 0x0F;
                if (nibble > 0x09) {
                    return nil;
                }
                break;

            case 0x40:
            case 0x60:
                /* chars a-f at ascii 0x41-0x46 and 0x61-0x66 */
                nibble &= 0x0F;
                nibble += 0x09;
                if (nibble < 0x0A || nibble > 0x0F) {
                    return nil;
                }
                break;

            default:
                return nil;
                break;
        }

        if (atLowNibble) {
            /* if we're at the low nibble, add it to the high one and append it to the output */
            byte |= nibble;
            [result appendBytes:&byte length:1];
            byte = 0;
        }
        else {
            /* we've parsed the high nibble, memorize it and proceed with the low nibble */
            byte = nibble << 4;
        }

        atLowNibble = 1 - atLowNibble;
    }

    return [[result copy] autorelease];
}

@end
