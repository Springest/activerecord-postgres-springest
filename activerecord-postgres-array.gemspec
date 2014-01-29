Gem::Specification.new do |s|
  s.name = "activerecord-postgres-springest"
  s.version = "0.0.9.tinfoil.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Connor"]
  s.date = %q{2012-02-08}
  s.description = "Adds support for postgres arrays to ActiveRecord"
  s.email = "tlconnor@gmail.com"
  s.homepage = "https://github.com/tlconnor/activerecord-postgres-springest"
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
