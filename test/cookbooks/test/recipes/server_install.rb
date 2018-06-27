edb_repository 'install'

edb_server_install 'package' do
  action [:install, :create]
end

# Using this to generate a service resource to control
find_resource(:service, 'edb-as9.6-server') do
  extend EnterprisedbCookbook::Helpers
  service_name lazy { platform_service_name }
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end

edb_server_conf 'EDBAS Config' do
  notifies :reload, 'service[edb-as9.6-server]'
end
