Gem::Specification.new do |s|
	s.name = 'apache-vhosts-parser'
	s.version = '0.2.1'
	s.date = '2014-05-19'
	s.description = "Parses apache2 vhosts. Have a look at the spec files to see how the API works!"
	s.summary = 'Sometimes you need some info from an Apache vhosts file or directory. This gem helps.'
	s.authors = ["François-Marie de Jouvencel"]
	s.email = 'fm.de.jouvencel@gmail.com'
	s.files = Dir.glob("{lib,spec}/**/*")
	s.homepage = 'https://github.com/djfm/apache-vhosts-parser'
	s.license = 'OSL'
end
