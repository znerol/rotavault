//
//  LCSRotavaultActivityController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultActivityController.h"

@implementation LCSRotavaultActivityController
- (IBAction)togglePanelVisibility:(id)sender {
    if ([[activityTable window] isVisible]) {
        [[activityTable window] orderOut:self];
    }
    else {
        [[activityTable window] orderFront:self];
    }
}

- (void)awakeFromNib
{
    _queue = [[NSOperationQueue alloc] init];
    [_queue addObserver:self forKeyPath:@"operations" options:0 context:nil];
}

- (void)dealloc
{
    [_queue removeObserver:self forKeyPath:@"operations"];
    [_queue release];
    [super dealloc];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    if (row < 0 || row >= [[_queue operations] count]) {
        return nil;
    }
    
    return [[[_queue operations] objectAtIndex:row] description];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return [[_queue operations] count];
}

-(void)operation:(LCSOperation*)op handleException:(NSException*)exception
{
    NSLog(@"UNHANDLED EXCEPTION: %@:%@", [op description], [exception description]);
    [_queue cancelAllOperations];
}

-(void)operation:(LCSOperation*)op handleError:(NSError*)error
{
    if ([error domain] != NSCocoaErrorDomain || [error code] != NSUserCancelledError) {
        [[NSApplication sharedApplication] presentError:error];
    }
    
    [_queue cancelAllOperations];
    
    NSLog(@"ERROR: %@", [error localizedDescription]);
}

-(void)operation:(LCSOperation*)op updateProgress:(NSNumber*)progress
{
    NSLog(@"PROGR: %.2f", [progress floatValue]);
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [activityTable reloadData];    
}

-(void)runOperation:(LCSOperation*)operation
{
    operation.delegate = self;
    [_queue addOperation:operation];
}
@end
