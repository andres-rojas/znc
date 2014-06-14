# Encoding: utf-8
require 'chefspec'
require 'chefspec/berkshelf'

::LOG_LEVEL = :fatal
::UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '14.04',
  log_level: ::LOG_LEVEL
}
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

PLATFORMS = {
  'ubuntu' => %w( 10.04 12.04 14.04 ),
  'centos' => %w( 6.4 6.5 )
}

at_exit { ChefSpec::Coverage.report! }
