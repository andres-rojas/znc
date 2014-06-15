require 'serverspec'

include Serverspec::Helper::Exec
include SpecInfra::Helper::Debian

describe 'ZNC' do

  user  = 'znc'
  group = 'znc'

  dir = Hash.new
  dir[:data]   = '/etc/znc'
  dir[:conf]   = "#{dir[:data]}/configs"
  dir[:module] = "#{dir[:data]}/modules"
  dir[:users]  = "#{dir[:data]}/users"

  it 'is running' do
    expect(command('pgrep znc')).to return_exit_status 0
  end

  describe user(user) do
    it { should exist }
    it { should belong_to_group group }
  end

  describe group(group) do
    it { should exist }
  end

  dir.each do |type, path|
    context "created the #{type} directory" do
      describe file(path) do
        it { should be_directory }
        it { should be_owned_by user }
        it { should be_grouped_into group }
      end
    end
  end

  describe file("#{dir[:data]}/znc.pem") do
    it { should be_file }
    it { should be_owned_by user }
    it { should be_grouped_into group }
  end

  describe file('/etc/init.d/znc') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 755 }
  end

  describe file("#{dir[:conf]}/znc.conf") do
    it { should be_file }
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 666 }
  end
end
