edb_server_install 'EDB Postgres Advanced Server' do
  password '12345'
  port 5444
  setup_repo true
  action [:install, :create]
end

user 'edb'

edb_ident 'edb mapping' do
  mapname 'testmap'
  system_user 'edb'
  pg_user 'edb'
  notifies :reload, 'service[edb-as9.6-server]'
end

edb_ident 'enterprisedb mapping' do
  mapname 'testmap'
  system_user 'enterprisedb'
  pg_user 'edb_user'
  notifies :reload, 'service[edb-as9.6-server]'
end

edb_access 'support host superuser' do
  access_type 'host'
  access_db 'all'
  access_user 'support'
  access_addr '127.0.0.1/32'
  access_method 'md5'
  notifies :reload, 'service[edb-as9.6-server]'
end

edb_access 'edb mapping' do
  access_type 'local'
  access_db 'all'
  access_user 'all'
  access_method 'peer map=testmap'
  cookbook 'test'
  notifies :reload, 'service[edb-as9.6-server]'
end

edb_user 'edb_user' do
  superuser true
  password '67890'
  sensitive false
end

service 'edb-as9.6-server' do
  extend EnterprisedbCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action :nothing
end
