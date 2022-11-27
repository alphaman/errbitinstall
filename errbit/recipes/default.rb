#Set some vars
packname=node[:erbbit][:ruby_package_url].gsub(/^(.*)\//,"")
useddir=packname.gsub(/.tar.gz(.*)$/,"")
untarcmd="tar xvfz /root/#{packname}"

#To be run only once before installing packages
execute "aptitude_update" do
 command "apt update"
 not_if { ::File.exists?("#{node[:erbbit][:erbbitinstalldir]}/httpdocs/app.json") }
 action :run
end

#Setup all required system packages
node["erbbit"]["deppacks"].each do |packname|
 package packname
end

#Ruby 2.7.6. required
remote_file "/root/#{packname}" do
 source node[:erbbit][:ruby_package_url]
 backup false
 owner "root"
 group "root"
 action :create_if_missing
 not_if { ::File.exists?("/usr/local/bin/ruby") }
end

execute "untar_ruby" do
 command untarcmd
 cwd "/root"
 not_if { ::File.exists?("/usr/local/bin/ruby") }
 action :run
end

execute "install_ruby" do
 command "./configure && make && make install"
 cwd "/root/#{useddir}"
 not_if { ::File.exists?("/usr/local/bin/ruby") }
 action :run
end

file "/root/#{packname}" do
 action :delete
end

directory "/root/#{useddir}" do
 action :delete
 recursive true
end

#Install bundler
node["erbbit"]["gempacks"].each do |gempack|
 gem_package gempack
end

#Miniracer doesn't setup without this
execute "libv8_dir_symlink" do
 command "ln -s /usr/local/lib/ruby/gems/2.7.0/gems/libv8-node-18.8.0.0-x86_64-linux-musl/vendor/v8/x86_64-linux-musl /usr/local/lib/ruby/gems/2.7.0/gems/libv8-node-18.8.0.0-x86_64-linux-musl/vendor/v8/x86_64-linux"
 not_if { ::File.exists?("/usr/local/lib/ruby/gems/2.7.0/gems/libv8-node-18.8.0.0-x86_64-linux-musl/vendor/v8/x86_64-linux") }
 action :run
end

service "mongod" do
 subscribes :enable, "package[#{node["erbbit"]["mongodbpack"]}]", :immediately
 action :nothing
end

#Adds MongoDB key for package install
execute "add_mongo_key" do
 command "wget -qO - #{node[:erbbit][:mongokey]} | sudo apt-key add -"
 action :nothing
end

#Creates the aptitude file for the MongoDB repo
template "/etc/apt/sources.list.d/mongodb-org-6.0.list" do
 source "mongorepo.erb"
 owner "root"
 group "root"
 mode "0755"
 notifies :run, 'execute[add_mongo_key]', :immediately
 notifies :run, 'execute[aptitude_update]', :immediately
end

#Install MongoDB and start it
package node["erbbit"]["mongodbpack"] do
 notifies :start, "service[mongod]", :immediately
end

#Create the user/group for the deploy
group node[:erbbit][:erbbitgroup] do
 action :create
end

user node[:erbbit][:erbbituser] do
 gid node[:erbbit][:erbbitgroup]
 shell "/bin/false"
 manage_home true
 home node[:erbbit][:erbbitinstalldir]
 system false
 action :create
end

#Run Bundle Install and related
execute "rakebootstrap" do
 command "export ERRBIT_ADMIN_EMAIL=#{node[:erbbit][:adminemail]} && export ERRBIT_ADMIN_USER=#{node[:erbbit][:adminuser]} && export ERRBIT_ADMIN_PASSWORD=#{node[:erbbit][:adminpass]} && bundle exec rake errbit:bootstrap && chown #{node[:erbbit][:erbbituser]}.#{node[:erbbit][:erbbitgroup]} -R ."
 cwd "#{node[:erbbit][:erbbitinstalldir]}/httpdocs"
 action :nothing
end

execute "bundleinstall" do
 command "bundle install"
 cwd "#{node[:erbbit][:erbbitinstalldir]}/httpdocs"
 notifies :run, 'execute[rakebootstrap]', :immediately
 action :nothing
end

#Get Erbbit
git "#{node[:erbbit][:erbbitinstalldir]}/httpdocs" do
 repository node[:erbbit][:erbbitgitrepo]
 revision node[:erbbit][:erbbitgitbranch]
 action :sync
 notifies :run, 'execute[bundleinstall]', :immediately
 user node[:erbbit][:erbbituser]
 group node[:erbbit][:erbbitgroup]
end

#Create Service
service "erbbit.service" do
 subscribes :enable, "template[/usr/lib/systemd/system/erbbit.service]", :immediately
 action :nothing
end

template "/usr/lib/systemd/system/erbbit.service" do
 source "erbbit.service.erb"
 owner "root"
 group "root"
 mode "0755"
 notifies :start, "service[erbbit.service]", :immediately
end
