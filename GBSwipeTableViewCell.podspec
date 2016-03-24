
Pod::Spec.new do |s|

s.license      = { :type => 'MIT', :file => 'LICENSE' }

s.name         = "GBSwipeTableViewCell"
s.version      = "1.0.1"
s.summary      = "GBSwipeTableViewCell is like WeChat cell, easy and powerfull.'"

s.homepage     = "https://github.com/goodyboy6/"
s.author       = {"goodyboy6" => "xiaoluo.yxl@alibaba-inc.com"}

s.platform     = :ios, '7.0'
s.ios.deployment_target = '7.0'
s.requires_arc = true

s.source =  { :git => "https://github.com/goodyboy6/GBSwipeTableViewCell.git" , :tag => "1.0.1"}
s.source_files = "GBSwipeCell/Class/*.{h,m}"
s.public_header_files = "GBSwipeCell/Class/*.h"

end