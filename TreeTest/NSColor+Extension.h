#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSColor (Extension)

+ (NSColor *)colorFromHexString:(NSString *)hexString;
- (BOOL)isEqualToColor:(NSColor *)otherColor;

@end
