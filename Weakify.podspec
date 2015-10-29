
Pod::Spec.new do |s|
  s.name             = "Weakify"
  s.version          = "0.2.1"
  s.summary          = "Weakly apply an object to a curried static method safely"
  s.description      = <<-DESC
                        Weakify is a µframework providing some commonly useful variations of the weakify() function. weakify() is primarily a way to be able to use a method on a class as a closure value that would be managed by some other component, but in a way that prevents memory leaks from occurring.
                       DESC

  s.homepage         = "https://github.com/klundberg/Weakify"
  s.license          = 'MIT'
  s.author           = { "Kevin Lundberg" => "kevin@klundberg.com" }
  s.source           = { :git => "https://github.com/klundberg/Weakify.git", :tag => "v#{s.version}" }
  s.social_media_url = 'https://twitter.com/kevlario'
  s.platforms = {
      :ios => "8.0",
      :osx => "10.9",
      :watchos => "2.0",
      :tvos => "9.0"
  }
  s.source_files = 'Weakify/**/*.swift'
end
