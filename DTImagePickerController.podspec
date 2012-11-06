Pod::Spec.new do |s|
  s.name         = "DTImagePickerController"
  s.version      = "0.0.1"
  s.summary      = "DTImagePickerController"
  s.author = 'David Renoldner', 'hello@davetrudes.com'
  s.homepage     = "http://www.davetrudes.com"
  s.source       = { :git => "https://github.com/dave-trudes/DTImagePickerController.git"}
  s.platform     = :ios, '4.0'
  s.source_files = 'DTImagePickerController'
  s.frameworks = 'AVFoundation', 'MobileCoreServices', 'QuartzCore', 'UIKit'
  s.requires_arc = true
end
