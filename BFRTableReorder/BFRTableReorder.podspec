Pod::Spec.new do |s|
s.name         = "BFRTableReorder"
s.version      = "0.0.1"
s.summary      = "Super simple tableview reordering via a long press 🍻"
s.description  = <<-DESC
The BFRTableReorder is a lightweight and unintrusive way to add tableview reordering via long press. It's an Objective-C port of the excellent SwiftReorder by Adam Shin, but tweaked and hacked to fit our own needs.
DESC
s.homepage      = "https://github.com/bufferapp/BFRReorderTableView"
s.screenshot    = "https://github.com/bufferapp/BFRReorderTableView/blob/master/reorder.png?raw=true"
s.license       = "MIT"
s.authors       = {"Andrew Yates" => "andy@bufferapp.com",
"Jordan Morgan" => "jordan@bufferapp.com"}
s.social_media_url = "https://twitter.com/bufferdevs"
s.source       = { :git => "https://github.com/bufferapp/BFRReorderTableView.git", :tag => '0.0.1'  }
s.source_files = 'Classes', 'BFRTableReorder/ReorderSource/**/*.{h,m}'
s.platform     = :ios, '9.0'
s.requires_arc = true
s.frameworks = "UIKit"
s.dependency = "AsyncDisplayKit", '>= 2.0'
end
