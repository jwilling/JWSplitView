#import "AppDelegate.h"
#import "JWSplitView.h"
#import "ColoredView.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CGRect b = [self.window.contentView bounds];
    
    JWSplitView *splitView = [[JWSplitView alloc] initWithFrame:b];
    [self.window.contentView addSubview:splitView];
    [splitView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [splitView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    splitView.horizontal = YES;
    splitView.autosaveName = @"TestSplitView";
    
    ColoredView *green = [[ColoredView alloc] initWithFrame:CGRectZero color:[NSColor greenColor]];
    ColoredView *red = [[ColoredView alloc] initWithFrame:CGRectZero color:[NSColor redColor]];
    ColoredView *blue = [[ColoredView alloc] initWithFrame:CGRectZero color:[NSColor blueColor]];
    
    [splitView addSplitView:green];
    [splitView addSplitView:red];
    [splitView addSplitView:blue];
}

@end
