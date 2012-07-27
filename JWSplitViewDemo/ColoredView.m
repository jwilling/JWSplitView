#import "ColoredView.h"

@implementation ColoredView

- (id)initWithFrame:(NSRect)frameRect color:(NSColor *)color {
    self = [super initWithFrame:frameRect];
    if (!self) return nil;
    self.color = color;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self.color set];
    NSRectFill(dirtyRect);
}

@end
