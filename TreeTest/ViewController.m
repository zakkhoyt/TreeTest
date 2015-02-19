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
#import "JPLabel.h"
#import "NSColor+Extension.h"

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


@interface JPTableRowView : NSTableRowView //NSTableCellView

@end

@implementation JPTableRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSColor *primaryColor = [NSColor colorFromHexString:@"586679"];
    NSColor *secondarySelectedControlColor = [NSColor colorFromHexString:@"586679"]; //535353
    
    //[[NSColor clearColor] set];
    
    // Implement our own custom alpha drawing
    switch (self.selectionHighlightStyle) {
        case NSTableViewSelectionHighlightStyleRegular: {
            if (self.selected) {
                if (self.emphasized) {
                    [primaryColor set];
                } else {
                    [secondarySelectedControlColor set];
                }
                NSRect bounds = self.bounds;
                const NSRect *rects = NULL;
                NSInteger count = 0;
                [self getRectsBeingDrawn:&rects count:&count];
                for (NSInteger i = 0; i < count; i++) {
                    NSRect rect = NSIntersectionRect(bounds, rects[i]);
                    NSRectFillUsingOperation(rect, NSCompositeSourceOver);
                }
            }
            break;
        }
        default: {
            // Do super's drawing
            [super drawSelectionInRect:dirtyRect];
            break;
        }
    }
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect {
    // Draw the grid
    NSRect sepRect = self.bounds;
    sepRect.origin.y = NSMaxY(sepRect) - 1;
    sepRect.size.height = 1;
    sepRect = NSIntersectionRect(sepRect, dirtyRect);
    if (!NSIsEmptyRect(sepRect)) {
        [[NSColor gridColor] set];
        NSRectFill(sepRect);
    }
}


@end

@interface JPOutliveView : NSOutlineView
- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row;
@end

@implementation JPOutliveView

- (id)makeViewWithIdentifier:(NSString *)identifier owner:(id)owner
{
    NSButton  *view = [super makeViewWithIdentifier:identifier owner:owner];
    
    if ([identifier isEqualToString:NSOutlineViewDisclosureButtonKey])
    {
        
        [view setImage:[NSImage imageNamed:@"folder"]];
        [view setAlternateImage:[NSImage imageNamed:@"folderOpen"]];
        
        view.frame = NSMakeRect(0, 0, 50, 19);
        return view;
    }
    
    return view;
}

//Frame of the disclosure view
- (NSRect)frameOfOutlineCellAtRow:(NSInteger)row
{
    NSRect superFrame = [super frameOfOutlineCellAtRow:row];
    superFrame.size.width = 30;
    return superFrame;
}
#define kOutlineCellWidth 30
#define kOutlineMinLeftMargin 50

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row {
    NSRect superFrame = [super frameOfCellAtColumn:column row:row];
    
    
    if (column == 0) {
        // expand by kOutlineCellWidth to the left to cancel the indent
        CGFloat adjustment = kOutlineCellWidth;
        
        // ...but be extra defensive because we have no fucking clue what is going on here
        if (superFrame.origin.x - adjustment < kOutlineMinLeftMargin) {
            NSLog(@"%@ adjustment amount is incorrect: adjustment = %f, superFrame = %@, kOutlineMinLeftMargin = %f", NSStringFromClass([self class]), (float)adjustment, NSStringFromRect(superFrame), (float)kOutlineMinLeftMargin);
            adjustment = MAX(0, superFrame.origin.x - kOutlineMinLeftMargin);
        }
        
        return NSMakeRect(superFrame.origin.x - adjustment, superFrame.origin.y, superFrame.size.width + adjustment, superFrame.size.height);
        
    }
    return superFrame;
}


- (NSCell *)preparedCellAtColumn:(NSInteger)column row:(NSInteger)row {
    // NSCell *cell =  [super viewAtColumn:column row:row makeIfNecessary:YES];
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

//
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    
    JPTableRowView *row = [[JPTableRowView alloc]init];
    
    return row;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    //    NSString *picturesPath = [NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"Pictures"];
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    //NSURL *new = [documentsDirectoryURL URLByAppendingPathComponent:@"Komposer"];
    
    self.pathControl.URL = documentsDirectoryURL;
    
    [self.view setWantsLayer:YES];
    self.view.layer.backgroundColor = [NSColor colorFromHexString:@"535353"].CGColor; //535353
    
    _outlineView.backgroundColor =[NSColor darkGrayColor]; //586679
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
        c.backgroundColor = [NSColor clearColor];
        c.font  = [NSFont systemFontOfSize:16];
        
        
    }else{
        NSLog(@"cell:%@",cell);
    }
}
-(NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(FileSystemItem*)item{
    JPTableRowView *row = [[JPTableRowView alloc]init];
    NSRect frame = [outlineView frameOfCellAtColumn:0 row: [outlineView rowForItem: item]];
    
    JPLabel *lbl = [[JPLabel alloc]initWithFrame:NSMakeRect(frame.origin.x+40, 0, 200, 40)];
    lbl.text = [item relativePath];
    [row addSubview:lbl];
    return row;
}




@end
