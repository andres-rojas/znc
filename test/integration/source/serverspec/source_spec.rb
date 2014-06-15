require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

os = backend(Serverspec::Commands::Base).check_os
packages =
  case os[:family]
  when 'Ubuntu', 'Debian'
    %w( libssl-dev libperl-dev pkg-config libc-ares-dev )
  else
    %w( openssl-devel perl-devel pkgconfig c-ares-devel )
  end

describe 'znc::source' do
  let(:version)       { '1.4' }
  let(:source_sha256) { '6dafcf12b15fdb95eac5b427c8507c1095e904b4' }

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
