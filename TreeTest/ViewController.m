//
//  ViewController.m
//  TreeTest
//
//  Created by Zakk Hoyt on 7/9/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "ViewController.h"
#import "VWWContentItem.h"
#import "FileSystemItem.h"


typedef void (^VWWEmptyBlock)(void);
typedef void (^VWWCLLocationCoordinate2DBlock)(CLLocationCoordinate2D coordinate);
typedef void (^VWWBoolDictionaryBlock)(BOOL success, NSDictionary *dictionary);





@interface ViewController ()
@property (weak) IBOutlet NSOutlineView *outlineView;
@property (weak) IBOutlet NSPathControl *pathControl;
//@property (strong) NSMutableArray *contents;
@property (strong) VWWContentItem *item;
@property (strong) NSIndexSet *selectedIndexes;


@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
                                    
    // Do any additional setup after loading the view.
    NSString *picturesPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Pictures"];
    self.pathControl.URL = [NSURL fileURLWithPath:picturesPath];
//    [FileSystemItem rootItemWithPath:self.pathControl.URL.path];
//    [self seachForFilesInDirectory:picturesPath];
    

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
                                    
    // Update the view, if already loaded.
                                
}
- (IBAction)pathControlAction:(NSPathControl *)sender {
    
}




// Data Source methods

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(FileSystemItem*)item {
    return (item == nil) ? 1 : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(FileSystemItem*)item {
    return (item == nil) ? YES : ([item numberOfChildren] != -1);
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(FileSystemItem*)item {
//    return (item == nil) ? [FileSystemItem rootItem] : [(FileSystemItem *)item childAtIndex:index];
    return (item == nil) ? [FileSystemItem rootItemWithPath:self.pathControl.URL.path] : [(FileSystemItem *)item childAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(FileSystemItem*)item {
    if([tableColumn.identifier isEqualToString:@"tree"]){
        return (item == nil) ? @"/" : (id)[item relativePath];
//        return (item == nil) ? @"Pictures" : (id)[item relativePath];
    } else if([tableColumn.identifier isEqualToString:@"coordinate"]){
        return @"coordinate";
    }

    return nil;
//    return (item == nil) ? self.pathControl.URL.path : (id)[item relativePath];
}

// Delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(FileSystemItem*)item {
    return NO;
}

@end
