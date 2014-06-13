# Encoding: utf-8
require 'chefspec'
require 'chefspec/berkshelf'
require 'fauxhai'

::LOG_LEVEL = :fatal
::UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '14.04',
  log_level: ::LOG_LEVEL
}
::CHEFSPEC_OPTS = {
  log_level: ::LOG_LEVEL
}

at_exit { ChefSpec::Coverage.report! }
