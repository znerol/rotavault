#import <Foundation/Foundation.h>
#import <SenTestingKit/SenTestingKit.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    SenTestSuite *suite = [SenTestSuite defaultTestSuite];
    SenTestRun *testrun = [suite run];
    int status = ([testrun hasSucceeded] != TRUE);

    [pool drain];
    return status;
}
