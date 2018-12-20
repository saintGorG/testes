control "nginx-installed" do
  impact 1.0
  title "Verificar que NginX está instalado"
  desc "Primer requisito del rol, debe instalar Nginx"
  describe package('nginx') do
    it { should be_installed }
  end
end

control "nginx-started-enabled" do
  impact 1.0
  title "Verificara que NginX está arrancado y que se arrancará al inicio del sistema"
  desc "Nginx arrancado y en enabled"
  describe service('nginx') do
   it { should be_enabled }
   it { should be_running }
  end
end

control "nginx-listens-80" do
  impact 1.0
  title "Verificar que NginX está escuchando en el puerto 80"
  desc "Nginx debe escuchar en el puerto 80 en este test"
  describe port(80) do
   it { should be_listening }
   its('processes') {should include 'nginx'} 
  end
end
