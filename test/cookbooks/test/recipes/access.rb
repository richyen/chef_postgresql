edb_server_install 'EDB Postgres Advanced Server' do
  password '12345'
  port 5444
  setup_repo true
  version '9.6'
  action [:install, :create]
end

edb_access 'enterprisedb host superuser' do
  access_type       'host'
  access_db         'all'
  access_user       'enterprisedb'
  access_addr       '127.0.0.1/32'
  access_method     'md5'
  notifies :reload, 'service[edb-as9.6-server]'
end

postgresql_user 'edb_user' do
  superuser true
  password 'EDB123'
  sensitive false
end

postgresql_access 'a edb_user local superuser' do
  access_type 'local'
  access_db 'all'
  access_user 'edb_user'
  access_method 'md5'
  access_addr nil
  notifies :reload, 'service[edb-as9.6-server]'
end

service 'edb-as9.6-server' do
  extend EnterprisedbCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end
