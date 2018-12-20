control "apache-started-enabled" do
  impact 1.0
  title "Verificara que Apache está arrancado y que se arrancará al inicio del sistema"
  desc "Apache arrancado y en enabled"
  describe service('apache') do
   it { should be_enabled }
   it { should be_running }
  end
end


