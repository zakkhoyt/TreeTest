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


@interface JPTextFieldCell : NSTextFieldCell
@property(nonatomic) int backgroundStyle;
@end

@implementation JPTextFieldCell
-(NSColor *)highlightColorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    return nil;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    if ([self isHighlighted]) {
        // Draw highlight background here
    }
    
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}
@end

@interface JPOutliveView : NSOutlineView


@end

@implementation JPOutliveView

- (id)makeViewWithIdentifier:(NSString *)identifier owner:(id)owner {
    id view = [super makeViewWithIdentifier:identifier owner:owner];
    
    if ([identifier isEqualToString:NSOutlineViewDisclosureButtonKey]) {
        // Do your customization
        NSLog(@"NSOutlineViewDisclosureButtonKey");
    }
    
    return view;
}

- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row {
    NSCell *cell = [super preparedCellAtColumn:column row:row];
    if (cell.isHighlighted && self.window.isKeyWindow) {
        cell.backgroundStyle = NSBackgroundStyleDark;
        cell.highlighted = NO;
    }
    
    return cell;
}

- (void)highlightSelectionInClipRect:(NSRect)clipRect {
    if (!self.window.isKeyWindow) {
        return [super highlightSelectionInClipRect:clipRect];
    }
    
    NSRange range = [self rowsInRect:clipRect];
    [[NSColor alternateSelectedControlColor] set];
    [self.selectedRowIndexes enumerateRangesInRange:range options:0 usingBlock:^(NSRange curRange, BOOL *stop) {
        for (NSUInteger row = curRange.location; row < NSMaxRange(curRange); ++row) {
            NSRect rect = [self rectOfRow:row];
            rect.size.height -= 1;
            [[NSColor redColor] set];
            NSRectFill(rect);
        }
    }];
}

@end

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
    //    NSString *picturesPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Pictures"];
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    //NSURL *new = [documentsDirectoryURL URLByAppendingPathComponent:@"Komposer"];
    
    self.pathControl.URL = documentsDirectoryURL;
    
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [NSColor blackColor].CGColor;
    
    _outlineView.backgroundColor =[NSColor blackColor];
    _outlineView.gridColor = [NSColor whiteColor];
    
    NSRect frame = _outlineView.headerView.frame;
    frame.size.height = 0;
    _outlineView.headerView.frame = frame;
    _outlineView.enclosingScrollView.borderType = NSNoBorder;
    [_outlineView setFocusRingType:NSFocusRingTypeNone];
    
    //     [_outlineView setControlTint:NSClearControlTint];
    
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
        return @"";
    }
    
    return nil;
    //    return (item == nil) ? self.pathControl.URL.path : (id)[item relativePath];
}

// Delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(FileSystemItem*)item {
    return NO;
}
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([cell isKindOfClass:[NSTextFieldCell class]]) {
        NSTextFieldCell *c = (NSTextFieldCell *)cell;
        c.textColor = [NSColor whiteColor];
        c.font  = [NSFont systemFontOfSize:15];
        //
        [c setControlTint:NSClearControlTint];
        //        if (c.isHighlighted) {
        //            [c setBackgroundColor:[NSColor blackColor]];
        //        }
        //        else {
        //            [c setBackgroundColor:[NSColor darkGrayColor]];
        //        }
        //        [c setDrawsBackground:YES];
        [c setFocusRingType:NSFocusRingTypeNone];
    }else{
        NSLog(@"cell:%@",cell);
    }
}



@end
