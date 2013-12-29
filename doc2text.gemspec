Gem::Specification.new do |s|
  s.name      = 'doc2text'
  s.version   = '0.1'
  s.authors   = 'Valentin Aitken'
  s.email     = 'bostko@gmail.com'
  s.homepage  = 'https://github.com/bostko/doc2text'
  s.license   = 'GPL'
  s.summary   = 'Translates doc to markdown and vice-versa'

  s.files     = `git ls-files -- lib/*`.split("\n")
end
