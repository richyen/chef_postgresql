# frozen_string_literal: true
name              'edb'
maintainer        'EnterpriseDB'
maintainer_email  'support@enterprisedb.com'
license           'Apache-2.0'
description       'Installs and configures EDB Postgres Advanced Server for clients or servers'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           '7.0.0'
source_url        'https://github.com/EnterpriseDB'
issues_url        'https://github.com/EnterpriseDB'
chef_version      '>= 13.8'

%w(fedora redhat centos).each do |os|
  supports os
end

depends 'build-essential', '>= 2.0.0'
depends 'openssl', '>= 4.0'
