Gem::Specification.new do |s|
  s.name      = 'doc2text'
  s.version   = '0.4.10'
  s.authors   = 'Valentin A.'
  s.email     = 'valentin@nalisbg.com'
  s.homepage  = 'http://doc2text.com'
  s.license   = 'Apache-2.0'
  s.summary   = 'Translates odt to markdown'
  s.description = 'Parses odt to markdown'

  s.add_runtime_dependency 'nokogiri', '~> 1.19'
  s.add_runtime_dependency 'rubyzip', '~> 3.2'
  s.files     = `git ls-files -- lib/* bin/doc2text`.split("\n")
  s.executables << 'doc2text'
end
