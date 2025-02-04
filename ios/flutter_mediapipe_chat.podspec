Pod::Spec.new do |s|
  s.name             = 'flutter_mediapipe_chat'
  s.version          = '1.0.0'
  s.summary          = 'A Flutter plugin for chat using MediaPipe'
  s.description      = 'Flutter plugin for real-time chat model inference using MediaPipe'
  s.homepage         = 'https://github.com/juandpt03/flutter_mediapipe_chat'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'Juan Penaloza' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MediaPipeTasksGenAI'
  s.dependency 'MediaPipeTasksGenAIC'
  s.platform = :ios, '15.0'

  s.static_framework = true 

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
