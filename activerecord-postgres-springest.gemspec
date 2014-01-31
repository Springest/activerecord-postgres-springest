Gem::Specification.new do |s|
  s.name = "activerecord-postgres-springest"
  s.version = "0.0.12.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Connor", "Peter de Ruijter"]
  s.date = %q{2014-01-31}
  s.description = "Adds support for postgres arrays and networktypes to ActiveRecord"
  s.email = "tlconnor@gmail.com"
  s.homepage = "https://github.com/Springest/activerecord-postgres-springest"
  s.files = ["Gemfile", "LICENSE", "Rakefile", "README.textile", "activerecord-postgres-springest.gemspec"] + Dir['**/*.rb']
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = s.description

  s.add_dependency "activerecord", '~> 3.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.12.0'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'activerecord-postgres-hstore'
  s.add_development_dependency 'combustion', '0.5.1'

end
