#!/usr/bin/env ruby
#^syntax detection

forge "https://forgeapi.puppetlabs.com"

# use dependencies defined in Modulefile
# modulefile

# A module from the Puppet Forge
mod 'puppetlabs-stdlib', '5.2.0'
mod 'puppetlabs-concat', '5.2.0'
mod 'puppetlabs-apt', '6.2.1'

# FIXME:
# you'll probably need some modules for your puppetserver
# consider using these:
# mod 'theforeman-puppet', '11.0.0'
# mod 'puppet-r10k', '7.0.0'

mod 'petems-hiera_vault',
  :git => 'https://github.com/petems/petems-hiera_vault',
  :ref => 'v0.4.1'
