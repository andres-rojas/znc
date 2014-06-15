require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

OS = backend(Serverspec::Commands::Base).check_os[:family]
