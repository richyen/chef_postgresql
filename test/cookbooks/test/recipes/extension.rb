edb_repository 'install'

edb_server_install 'package' do
  action [:install, :create]
end

edb_database 'test_1'

edb_extension 'adminpack' do
  source_directory '/usr/edb/as9.6/share/extension/'
  database 'test_1'
end
