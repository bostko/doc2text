Gem::Specification.new do |s|
  s.name      = 'doc2text'
  s.version   = '0.4.2'
  s.authors   = 'Valentin Aitken'
  s.email     = 'valentin@nalisbg.com'
  s.homepage  = 'http://doc2text.com'
  s.license   = 'Apache-2.0'
  s.summary   = 'Translates odt to markdown'
  s.description = 'Parses odt to markdown'

  s.add_runtime_dependency 'nokogiri', '~> 1.11.1'
  s.add_runtime_dependency 'rubyzip', '~> 2.0.0'
  s.files     = `git ls-files -- lib/* bin/doc2text`.split("\n")
  s.executables << 'doc2text'
end
