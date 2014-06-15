# Encoding: utf-8
require_relative 'spec_helper'

describe 'znc::source' do
  PLATFORMS.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version)
            .converge(described_recipe)
        end

        let(:checksum)     { '6dafcf12b15fdb95eac5b427c8507c1095e904b4' }
        let(:source_dest)  { "#{Chef::Config[:file_cache_path]}/znc-1.4.tar.gz" }

        before { stub_command('which znc').and_return(nil) }

        it 'installs the build-essential package' do
          expect(chef_run).to include_recipe('build-essential')
        end

        packages =
          case platform
          when 'debian', 'ubuntu'
            %w( libssl-dev libperl-dev pkg-config libc-ares-dev )
          else
            %w( openssl-devel perl-devel pkgconfig c-ares-devel )
          end

        context 'installs' do
          packages.each do |package|
            it package do
              expect(chef_run).to install_package(package)
            end
          end
        end

        context 'ZNC is not installed' do
          it 'downloads the source tarball' do
            expect(chef_run).to create_remote_file(source_dest).with(
              checksum: checksum,
              mode: '0644'
            )
          end

          it 'builds ZNC' do
            expect(chef_run).to run_bash('build znc')
              .with_cwd(Chef::Config[:file_cache_path])
          end
        end

        context 'ZNC is installed' do
          before { stub_command('which znc').and_return('/usr/bin/znc') }

          it 'does not download the source tarball' do
            expect(chef_run).to_not create_remote_file(source_dest)
          end

          it 'does not build ZNC' do
            expect(chef_run).to_not run_bash('build znc')
          end
        end
      end
    end
  end
end
