control "vim-installed" do
  impact 1.0
  title "Verificar que VI - Improved está instalado"
  desc "Ningún sistema puede sobrevivir sin el mejor editor del mundo"
  describe package('vim-enhanced') do
   it { should be_installed }
  end
end
