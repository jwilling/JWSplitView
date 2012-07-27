#import <Cocoa/Cocoa.h>

@interface ColoredView : NSView

@property (nonatomic, strong) NSColor *color;
- (id)initWithFrame:(NSRect)frameRect color:(NSColor *)color;

@end
