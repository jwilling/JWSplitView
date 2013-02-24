##Information

`JWSplitView` is a constraint-based replacement for NSSplitView. Although there are improvements to NSSplitView in OS X 10.8, I grew tired of the delegate methods and odd workarounds to prevent proportional resizing. The goal of `JWSplitView` is to eventually become a complete replacement for NSSplitView. The current version is far from complete.

This readme will be updated in the near future with more detailed information.

##Current Capabilities
As of now, `JWSplitView` does not do proportional resizing. However, it supports save & restore.
It also supports setting maximum and minimum sizes for its subviews.

##ToDo
The current version of `JWSplitView` is somewhat a proof-of-concept. There are a couple of things that aren't implemented that should be done immediately:

- Implement the block-based divider drawing (currently draws a black bar)
- Implement priority resizing options

##License
`JWSplitView` is licensed under the [BSD License](http://www.opensource.org/licenses/bsd-license).
