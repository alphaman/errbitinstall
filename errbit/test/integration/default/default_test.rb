describe port(8080) do
  it { should be_listening }
end

describe port(27017) do
  it { should be_listening }
end

describe package('git') do
  it { should be_installed }
end

describe package('mongodb-org') do
  it { should be_installed }
end

describe file("/var/www/erbit/httpdocs/app.json") do
  it { should exist }
end

describe file("/usr/lib/systemd/system/erbbit.service") do
  it { should exist }
end

describe passwd do
  its('users') { should include 'erbit' }
end

describe command('ruby -v') do
  its('stdout') { should match "2.7.6" }
end

describe service('mongod') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
 end

 describe service('erbbit') do
   it { should be_installed }
   it { should be_enabled }
   it { should be_running }
  end
