Pod::Spec.new do |s|
  s.name         = "BFRTableReorder"
  s.version      = "0.0.3"
  s.summary      = "An easy way to add reordering to your amazing ASDK apps!"
  s.description  = <<-DESC
  				   The BFRTableReorder is an out of the box solution to add long press reordering to your ASDK apps, specifically with ASTableNode!
                   We use it all over the place in Buffer for iOS :-).
                   DESC
  s.homepage     = "https://github.com/bufferapp/BFRReorderTableView"
  s.screenshot   = "https://github.com/bufferapp/BFRReorderTableView/blob/master/demo.png?raw=true"
  s.license      = "MIT"
  s.author       =     {"Andrew Yates" => "andy@bufferapp.com",
  					   "Jordan Morgan" => "jordan@bufferapp.com"}
  s.source       = { :git => "https://github.com/bufferapp/BFRReorderTableView.git", :tag => "0.0.3" }
  s.source_files  = "Classes", "BFRTableReorder/ReorderSource/*.{h,m}"
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.dependency 'AsyncDisplayKit', '>= 2.0'
end
