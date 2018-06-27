# frozen_string_literal: true
#
# Cookbook:: edb
# Resource:: repository
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

property :version,         String, default: '9.6'
property :yum_gpg_key_uri, String, default: 'https://yum.enterprisedb.com/ENTERPRISEDB-GPG-KEY'
property :cookbook,        String, default: 'edb'
property :edb_username,    String, default: ''
property :edb_password,    String, default: ''

action :add do
  case node['platform_family']

  when 'rhel', 'fedora'
    remote_file '/etc/pki/rpm-gpg/ENTERPRISEDB-GPG-KEY' do
      source new_resource.yum_gpg_key_uri
    end

    template '/etc/yum.repos.d/edb.repo' do |new_resource|
        cookbook new_resource.cookbook
          source 'edb.repo.erb'
           owner 'root'
           group 'wheel'
            mode '0644'
          variables[:edb_username] = new_resource.edb_username
          variables[:edb_password] = new_resource.edb_password
        variables[:enable_version] = new_resource.version.delete('.')
    end
  else
    raise "The platform_family '#{node['platform_family']}' or platform '#{node['platform']}' is not supported by the edb_repository resource. If you believe this platform can/should be supported by this resource please file and issue or open a pull request at https://github.com/EnterpriseDB"
  end
end

action_class do
  include EnterprisedbCookbook::Helpers
end
