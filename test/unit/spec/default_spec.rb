# Encoding: utf-8
require_relative 'spec_helper'

describe 'znc::default' do
  let(:chef_run) do
    stub_command('pgrep znc').and_return('')

    ChefSpec::Runner.new.converge(described_recipe)
  end

  let(:install_method) { 'package' }
  let(:user)           { 'znc' }
  let(:group)          { 'znc' }

  dir = Hash.new
  dir[:data]   = '/etc/znc'
  dir[:conf]   = "#{dir[:data]}/configs"
  dir[:module] = "#{dir[:data]}/modules"
  dir[:users]  = "#{dir[:data]}/users"

  it 'includes the `znc::{install_method}` recipe' do
    expect(chef_run).to include_recipe("znc::#{install_method}")
  end

  context 'user management' do
    it 'creates a znc user' do
      expect(chef_run).to create_user(user)
    end

    it 'creates a znc group' do
      expect(chef_run).to create_group(group)
    end
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

  it 'generates a pem file' do
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
end
