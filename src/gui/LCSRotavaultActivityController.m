//
//  LCSRotavaultActivityController.m
//
//  Created by Lorenz Schori on 18.09.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LCSRotavaultActivityController.h"
#import "LCSOperationQueueOperation.h"

@implementation LCSRotavaultActivityController
- (IBAction)togglePanelVisibility:(id)sender {
    if ([[activityOutline window] isVisible]) {
        [[activityOutline window] orderOut:self];
    }
    else {
        [[activityOutline window] orderFront:self];
    }
}

- (void)awakeFromNib
{
    activeOperations = [[NSMutableArray alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    [_queue addObserver:self forKeyPath:@"operations" options:0 context:nil];
    originalThread = [NSThread currentThread];
}

- (void)dealloc
{
    [_queue removeObserver:self forKeyPath:@"operations"];
    [_queue release];
    [activeOperations release];
    [super dealloc];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    NSArray *ops = (item == nil) ? _queue.operations : ((LCSOperationQueueOperation *)item).queue.operations;
    return [ops count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? NO : [item isKindOfClass:[LCSOperationQueueOperation class]];
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    NSArray *ops = (item == nil) ? _queue.operations : ((LCSOperationQueueOperation *)item).queue.operations;
    return [ops objectAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return [item description];
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

-(void)reloadActivityView
{
    [activityOutline expandItem:nil expandChildren:YES];
    [activityOutline reloadData];    
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if (![keyPath isEqualToString:@"operations"]) {
        return;
    }
    
    [self performSelector:@selector(reloadActivityView) onThread:originalThread withObject:nil waitUntilDone:NO];
}

-(void)runOperation:(LCSOperation*)operation
{
    operation.delegate = self;
    [_queue addOperation:operation];
}
@end
