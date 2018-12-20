control "apache-listens-80" do
  impact 1.0
  title "Verificar que Apache está escuchando en el puerto 80"
  desc "Apache debe escuchar en el puerto 80 en este test"
  describe port(80) do
   it { should be_listening }
   its('processes') {should include 'apache'}
  end
end
