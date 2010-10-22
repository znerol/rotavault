#import <Foundation/Foundation.h>
#import "LCSCommand.h"
#import "LCSDiskInfoCommand.h"
#import "LCSPropertyListSHA1Hash.h"
#import "NSData+Hex.h"

typedef enum {
    kLCSSHA1,
    kLCSUUID,
} LCSChecksumAlgo;

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    /* process command line arguments */
    NSUserDefaults *args = [[[NSUserDefaults alloc] init] autorelease];
    [args addSuiteNamed:NSArgumentDomain];

    NSString* device;
    LCSChecksumAlgo algo;
    if ((device = [args objectForKey:@"sha1"])) {
        algo = kLCSSHA1;
    }
    else if ((device = [args objectForKey:@"uuid"])) {
        algo = kLCSUUID;
    }
    else {
        fprintf(stderr, "Usage: rvcksum [-sha1|-uuid] /dev/diskX[sY]\n");
        return 1;
    }

    LCSCommand *ctl = [LCSDiskInfoCommand commandWithDevicePath:device];
    [ctl start];
    [ctl waitUntilDone];
    
    if (ctl.result == nil) {
        fprintf(stderr, "Unable to gather information for specified device path\n");
        return 1;
    }

    NSString *cksum;
    switch (algo) {
        case kLCSSHA1:
            cksum = [[LCSPropertyListSHA1Hash sha1HashFromPropertyList:ctl.result] stringWithHexBytes];
            if(!cksum) {
                fprintf(stderr, "Failed to calculate SHA1 checksum for disk info of the specified device path\n");
                return 1;
            }
            printf("sha1:%s\n", [cksum cStringUsingEncoding:NSASCIIStringEncoding]);
            break;

        case kLCSUUID:
            cksum = [ctl.result objectForKey:@"VolumeUUID"];
            if(!cksum) {
                fprintf(stderr, "Failed to retreive volume UUID for the specified device path\n");
                return 1;
            }
            printf("uuid:%s\n", [cksum cStringUsingEncoding:NSASCIIStringEncoding]);
            break;

        default:
            fprintf(stderr, "Internal error, unkexpected checksum algorithm\n");
            return 1;
    }

    [pool drain];
    return 0;
}
