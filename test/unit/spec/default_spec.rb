# Encoding: utf-8
require_relative 'spec_helper'

describe 'znc::default' do
  [
    {
      platform: 'ubuntu',
      platform_family: 'debian',
      versions: %w( 10.04 12.04 14.04 )
    },
    {
      platform: 'centos',
      platform_family: 'rhel',
      versions: %w( 6.4 6.5 )
    }
  ].each do |os|
    os[:versions].each do |os_version|
      context "on #{os[:platform]} #{os_version}" do
        %w( package source ).each do |install_method|
          context "installed via #{install_method}" do
            let(:chef_run) do
              ChefSpec::Runner.new do |node|
                node.automatic['platform_family'] = os[:platform_family]
                node.set['znc']['install_method'] = install_method
              end.converge(described_recipe)
            end

            let(:user)  { 'znc' }
            let(:group) { 'znc' }

            dir = Hash.new
            dir[:data]   = '/etc/znc'
            dir[:conf]   = "#{dir[:data]}/configs"
            dir[:module] = "#{dir[:data]}/modules"
            dir[:users]  = "#{dir[:data]}/users"

            let(:znc_conf_path) { "#{dir[:conf]}/znc.conf" }

            before do
              Fauxhai.mock(platform: os[:platform], version: os_version)
              stub_command('pgrep znc').and_return('')
              stub_command('which znc').and_return('')
            end

            it "includes the `znc::#{install_method}` recipe" do
              expect(chef_run).to include_recipe("znc::#{install_method}")
            end

            it 'creates a znc user' do
              expect(chef_run).to create_user(user)
            end

            it 'creates a znc group' do
              expect(chef_run).to create_group(group)
            end

            context 'creates directories with znc user/group' do
              dir.each do |type, path|
                it type do
                  expect(chef_run).to create_directory(path).with(
                    owner: user,
                    group: group
                  )
                end
              end
            end

            it 'generates the pem file' do
              expect(chef_run).to run_bash('generate-pem').with(
                cwd: dir[:data],
                user: user,
                group: group,
                creates: "#{dir[:data]}/znc.pem"
              )
            end

            it 'generates an init script' do
              expect(chef_run).to create_template('/etc/init.d/znc').with(
                source: 'znc.init.erb',
                owner: 'root',
                group: 'root',
                mode: '0755'
              )
            end

            it 'saves the config' do
              expect(chef_run).to run_execute('force-save-znc-config')
            end

            it 'prepares to reload the config' do
              expect(chef_run.execute('reload-znc-config')).to do_nothing
            end

            it 'generates the config' do
              expect(chef_run).to create_template(znc_conf_path).with(
                source: 'znc.conf.erb',
                mode: '0600',
                owner: user,
                group: group,
                variables: { users: [] }
              )
            end

            it 'reloads the config' do
              expect(chef_run.template(znc_conf_path))
                .to notify('execute[reload-znc-config]').to(:run).immediately
            end

            context 'starts ZNC' do
              it 'enables' do
                expect(chef_run).to enable_service('znc')
              end

              it 'starts' do
                expect(chef_run).to start_service('znc')
              end
            end
          end
        end
      end
    end
  end
end
