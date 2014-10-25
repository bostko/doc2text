Gem::Specification.new do |s|
  s.name      = 'doc2text'
  s.version   = '0.3.2'
  s.authors   = 'Valentin Aitken'
  s.email     = 'bostko@gmail.com'
  s.homepage  = 'http://doc2text.com'
  s.license   = 'GPL'
  s.summary   = 'Translates odt to markdown'
  s.description = 'Parses odt to markdown'

  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.3'
  s.add_runtime_dependency 'rubyzip', '~> 1.1', '>= 1.1.6'
  s.files     = `git ls-files -- lib/*`.split("\n")
end
