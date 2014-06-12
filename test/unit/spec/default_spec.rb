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

  @data_dir   = '/etc/znc'
  @conf_dir   = "#{@data_dir}/configs"
  @module_dir = "#{@data_dir}/modules"
  @users_dir  = "#{@data_dir}/users"

  it 'includes the `znc::{install_method}` recipe' do
    expect(chef_run).to include_recipe("znc::#{install_method}")
  end

  it 'creates a znc user' do
    expect(chef_run).to create_user(user)
  end

  it 'creates a znc group' do
    expect(chef_run).to create_group(group)
  end

  [@data_dir, @conf_dir, @module_dir, @users_dir].each do |dir|
    it dir do
      expect(chef_run).to create_directory(dir).with(
        owner: user,
        group: group
      )
    end
  end

  it 'generates a pem file' do
    expect(chef_run).to run_bash('generate-pem').with(
      cwd: @data_dir,
      user: user,
      group: group,
      creates: "#{@data_dir}/znc.pem"
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
