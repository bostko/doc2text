Gem::Specification.new do |s|
  s.name      = 'doc2text'
  s.version   = '0.4.0'
  s.authors   = 'Valentin Aitken'
  s.email     = 'valentin@nalisbg.com'
  s.homepage  = 'http://doc2text.com'
  s.license   = 'Apache-2.0'
  s.summary   = 'Translates odt to markdown'
  s.description = 'Parses odt to markdown'

  s.add_runtime_dependency 'nokogiri', '~> 1.8', '>= 1.8.2'
  s.add_runtime_dependency 'rubyzip', '~> 1.2', '>= 1.2.2'
  s.files     = `git ls-files -- lib/* bin/doc2text`.split("\n")
  s.executables << 'doc2text'
end
