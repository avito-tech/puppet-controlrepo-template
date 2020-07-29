source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ %r{\A(git[:@][^#]*)#(.*)}
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place_or_version =~ %r{\Afile:\/\/(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

def gem_type(place_or_version)
  if place_or_version =~ %r{\Agit[:@]}
    :git
  elsif !place_or_version.nil? && place_or_version.start_with?('file:')
    :file
  else
    :gem
  end
end

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem 'fast_gettext',     '1.1.0',                     require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.1.0')
  gem 'fast_gettext',                                  require: false if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.1.0')
  gem 'json_pure',        '<= 2.0.1',                  require: false if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
  gem 'json',             '= 1.8.1',                   require: false if Gem::Version.new(RUBY_VERSION.dup) == Gem::Version.new('2.1.9')
  gem 'json',             '<= 2.0.4',                  require: false if Gem::Version.new(RUBY_VERSION.dup) == Gem::Version.new('2.4.4')
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem 'yard',                                          require: false
  gem 'puppet-strings',                                require: false
  gem 'puppet-blacksmith',                             require: false
  gem 'librarianp',       '~> 0.6.4.1',                require: false
  gem 'librarian-puppet', '~> 3.0.0',                  require: false
  gem 'test-kitchen',     '~> 1.23.2',                 require: false
  gem 'kitchen-puppet',   '~> 3.4.1',                  require: false
  gem 'kitchen-docker',   '~> 2.9.0',                  require: false
  gem 'kitchen-inspec',   '~> 0.24.0',                 require: false
  gem 'kitchen-sync',     tag: 'v2.2.1',               git: 'https://github.com/coderanger/kitchen-sync.git'
  gem 'rspec_junit_formatter'
end

puppet_version = ENV['PUPPET_GEM_VERSION']
puppet_type = gem_type(puppet_version)
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables

gems['facter'] = location_for(facter_version) if facter_version
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
