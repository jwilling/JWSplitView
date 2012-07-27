/*
 Copyright (c) 2012, Jonathan Willing
 All rights reserved.
 Licensed under the BSD License.
 http://www.opensource.org/licenses/bsd-license
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met: Redistributions of source code must retain the
 above copyright notice, this list of conditions and the following disclaimer. Redistributions
 in binary form must reproduce the above copyright notice, this list of conditions and the
 following disclaimer in the documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
