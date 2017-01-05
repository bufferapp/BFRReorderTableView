#BFRTableReorder#

<p align="center">
  <img src="/demo.gif?raw=true" alt="Demo" />
</p>
<p align="center">
  <img src="https://img.shields.io/cocoapods/p/BFRTableReorder.svg" />
  <img src="https://img.shields.io/cocoapods/v/BFRTableReorder.svg" />
  <img src="https://img.shields.io/cocoapods/l/BFRTableReorder.svg" />
</p>

###Summary###
The BFRTableReorder is an out of the box solution to add long press reordering to your [ASDK](https://github.com/facebook/AsyncDisplayKit) apps 🎉! It started off as an Objective-C port of the excellent [Swift Reorder](https://github.com/adamshin/SwiftReorder/) by Adam Shin, but we ended up hacking it apart for ASDK purposes.

We use it all over the place in [Buffer for iOS](https://itunes.apple.com/us/app/buffer-for-twitter-pinterest/id490474324?mt=8) :-).

###Installation###
The BFRTableReorder is hosted on CocoaPods and is the recommended way to install it:
```ruby
pod 'BFRTableReorder'
```


###Quickstart###
To kick things off, you need to include one header file anywhere you want some reordering action to happen 😊:
```objc
#import "ASTableNode+BFRReorder.h"
```

This will add the `reorder` property to any table node instance via a category. To get up and running quickly with BFRTableReorder, just set your controller as the delegate off of any `ASTableNode`'s `reorder` property:
```objc
self.tableNode.reorder.delegate = self;
```

From there, you're only required to implement one delegate method, but there are several optional ones that can help out as well:
```objc
- (void)tableNode:(ASTableNode *)tableNode redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
```

There is a very simple example in the demo project, feel free to fire it up if you want to see all the delegate methods in action 💯.

###Going Forward###
We regularly maintain this code, and you can also rest assured that it's been battle tested against thousands of users in production 👍. That said, we get things wrong from time to time - so feel free to open an issue for anything you spot!

We are always happy to talk shop, so feel free to give us a shout on Twitter:

+ Andy - [@ay8s](http://www.twitter.com/ay8s)
+ Jordan - [@jordanmorgan10](http://www.twitter.com/jordanmorgan10)

Or, hey - why not work on the BFRTableReorder and get paid for it!? [We're hiring](http://www.buffer.com/journey)!

- - -
######Licence######
_This project uses MIT License._
