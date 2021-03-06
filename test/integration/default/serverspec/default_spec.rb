require_relative 'spec_helper'

packages =
  case OS
  when 'Ubuntu', 'Debian'
    %w( znc znc-dev znc-extra znc-webadmin )
  else
    %w( znc znc-devel )
  end

if OS == 'Ubuntu'
  os_version = `lsb_release -r | awk '{ print $2 }'`.to_f

  packages.delete('znc-extra')    if os_version >= 14.04
  packages.delete('znc-webadmin') if os_version > 10.04
end

describe 'znc::package' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end
end

require_relative '_default'
