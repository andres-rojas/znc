# Encoding: utf-8
require_relative 'spec_helper'

describe 'znc::package' do
  PLATFORMS.each do |platform, versions|
    versions.each do |version|
      context "on #{platform} #{version}" do
        let(:chef_run) do
          ChefSpec::Runner.new(platform: platform, version: version)
            .converge(described_recipe)
        end

        packages =
          case platform
          when 'debian', 'ubuntu'
            %w( znc znc-dev znc-extra znc-webadmin )
          else
            %w( znc znc-devel )
          end

        if platform == 'ubuntu'
          packages.delete('znc-extra') if version.to_f >= 14.04
          packages.delete('znc-webadmin') if version.to_f > 10.04
        end

        context 'installs' do
          packages.each do |package|
            it package do
              expect(chef_run).to install_package(package)
            end
          end
        end
      end
    end
  end
end
