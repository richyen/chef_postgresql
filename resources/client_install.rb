# frozen_string_literal: true
#
# Cookbook:: edb
# Resource:: client_install
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

property :version,    String, default: '9.6'
property :setup_repo, [true, false], default: true
property :edb_username,    String, default: ''
property :edb_password,    String, default: ''

action :install do
  edb_repository 'Add yum.enterprisedb.com repository' do
    version        new_resource.version
    edb_username   new_resource.edb_username
    edb_password   new_resource.edb_password
    only_if { new_resource.setup_repo }
  end

  case node['platform_family']
  when 'rhel', 'fedora'
    ver = new_resource.version.delete('.')
    package "edb-as#{ver}-server-client"
  end
end
