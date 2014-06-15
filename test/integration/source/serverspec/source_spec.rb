require_relative 'spec_helper'

packages =
  case OS
  when 'Ubuntu', 'Debian'
    %w( libssl-dev libperl-dev pkg-config libc-ares-dev )
  else
    %w( openssl-devel perl-devel pkgconfig c-ares-devel )
  end

describe 'znc::source' do
  packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  it 'installs ZNC' do
    expect(command('which znc')).to return_exit_status 0
  end
end

require_relative '_default'
