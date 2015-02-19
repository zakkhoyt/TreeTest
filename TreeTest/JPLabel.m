//
//  JPLabel.m
//  VVOpenSource
//
//  Created by John Pope on 22/01/2015.
//
//

#import "JPLabel.h"

@implementation JPLabel

#pragma mark INIT
//- (BOOL)isFlipped {
//    return YES;
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self textFieldToLabel];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self textFieldToLabel];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self textFieldToLabel];
    }
    return self;
}

#pragma mark SETTER
- (void)setFontSize:(CGFloat)fontSize {
    super.font = [NSFont fontWithName:self.font.fontName size:fontSize];
}

- (void)setText:(NSString *)text {
    [super setStringValue:text];
}

#pragma mark GETTER
- (CGFloat)fontSize {
    return super.font.pointSize;
}

- (NSString *)text {
    return [super stringValue];
}

#pragma mark - PRIVATE
- (void)textFieldToLabel {
    self.backgroundColor = [NSColor clearColor];
    super.bezeled = NO;
    super.drawsBackground = NO;
    super.editable = NO;
    super.selectable = NO;
}

//- (NSView *)hitTest:(NSPoint)aPoint {
//    if (self.subviews.count) return self;
//    return nil;
//}

@end

@implementation JPNohitLablel

- (NSView *)hitTest:(NSPoint)aPoint {
    return nil;
}

@end
