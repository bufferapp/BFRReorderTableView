#BFRTableReorder#

<p align="center">
  <img src="/demo.png?raw=true" alt="Demo" />
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
To get up and running quickly with BFRTableReorder, just initialize it by accessing the property off of any `ASTableNode` and setting its delegate property. From there, you're only required to implement one delegate method, but there are several optional ones that can help out as well:
```objc
- (void)tableNode:(ASTableNode *)tableNode redorderRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
```

Of course, you need to include one header file wherever you want some reordering action to happen 😊:
```objc
#import "ASTableNode+BFRReorder.h"
```

###Going Forward###
We regularly maintain this code, and you can also rest assured that it's been battle tested against thousands of users in production 👍. That said, we get things wrong from time to time - so feel free to open an issue for anything you spot!

We are always happy to talk shop, so feel free to give us a shout on Twitter:

+ Andy - [@ay8s](http://www.twitter.com/ay8s)
+ Jordan - [@jordanmorgan10](http://www.twitter.com/jordanmorgan10)
+ Humber - [@goku2](http://www.twitter.com/goku2)

Or, hey - why not work on the BFRTableReorder and get paid for it!? [We're hiring](http://www.buffer.com/journey)!

- - -
######Licence######
_This project uses MIT License._
