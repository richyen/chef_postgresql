# frozen_string_literal: true
#
# Cookbook:: edb
# Resource:: server_install
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

include EnterprisedbCookbook::Helpers

property :version,           String, default: '9.6'
property :setup_repo,        [true, false], default: true
property :hba_file,          String, default: lazy { "#{conf_dir}/main/pg_hba.conf" }
property :ident_file,        String, default: lazy { "#{conf_dir}/main/pg_ident.conf" }
property :external_pid_file, String, default: lazy { "/var/run/edb/#{version}-main.pid" }
property :password,          [String, nil], default: 'generate' # Set to nil if we do not want to set a password
property :port,              [String, Integer], default: 5444
property :initdb_locale,     String, default: 'UTF-8'

# Connection preferences
property :user,     String, default: 'enterprisedb'
property :database, String, default: 'edb'
property :host,     [String, nil]
property :port,     Integer, default: 5444

property :edb_username,    String, default: ''
property :edb_password,    String, default: ''

action :install do
  node.run_state['epas'] ||= {}
  node.run_state['epas']['version'] = new_resource.version

  edb_client_install 'EDB Postgres Advanced Server Client' do
    version      new_resource.version
    edb_username new_resource.edb_username
    edb_password new_resource.edb_password
    setup_repo   new_resource.setup_repo
  end

  package server_pkg_name
end

action :create do
  ENV['PGDATA'] = "#{conf_dir}"
  execute 'init_db' do
    command rhel_init_db_command
    user 'enterprisedb'
    not_if { initialized? }
    only_if { platform_family?('rhel', 'fedora') }
  end

  directory "#{conf_dir}/pg_log" do
    owner 'enterprisedb'
    group 'enterprisedb'
    mode '0700'
    action :create
  end

  # We use to use find_resource here.
  # But that required the user to do the same in t heir recipe.
  # This also seemed to never trigger notifications, therefore requiring a log resource
  # to notify the enable/start on the service, which always fires (Check v7.0 tag for more)
  service "edb-as#{new_resource.version}-server" do
    service_name platform_service_name
    supports restart: true, status: true, reload: true
    action [:enable, :start]
  end

  # Generate a random password or set it as per new_resource.password.
  bash 'generate-enterprisedb-password' do
    user 'enterprisedb'
    database 'edb'
    code alter_role_sql(new_resource)
    not_if { user_has_password?(new_resource) }
    not_if { new_resource.password.nil? }
  end
end

action_class do
  include EnterprisedbCookbook::Helpers
end
