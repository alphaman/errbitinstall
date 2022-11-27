default[:erbbit][:deppacks] = ["git","gnupg","wget","libreadline-dev","zlib1g-dev", "libssl-dev", "libxml2-dev","build-essential"]
default[:erbbit][:mongodbpack] = "mongodb-org"
default[:erbbit][:mongokey] = "https://www.mongodb.org/static/pgp/server-6.0.asc"
default[:erbbit][:mongorepofile] = "/etc/apt/sources.list.d/mongodb-org-6.0.list"
default[:erbbit][:mongorepofilecontent] = "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse"
default[:erbbit][:erbbitgitrepo] = "https://github.com/errbit/errbit.git"
default[:erbbit][:erbbitgitbranch] = "main"
default[:erbbit][:erbbitinstalldir] = "/var/www/erbit"
default[:erbbit][:erbbituser] = "erbit"
default[:erbbit][:erbbitgroup] = "erbit"
default[:erbbit][:rbenvinstaller] = "https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer"
default[:erbbit][:gempacks] = ["bundler","libv8-node"]
default[:erbbit][:ruby_package_url] = "https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.6.tar.gz"
default[:erbbit][:adminuser] = "erbitadmin"
default[:erbbit][:adminemail] = "erbitadmin@example.com"
default[:erbbit][:adminpass] = "erbitpassword"
default[:erbbit][:port] = "8080"
