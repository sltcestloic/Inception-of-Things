Vagrant.configure("2") do |config|
    config.vm.define "lbertranS" do |server|
      server.vm.hostname = "lbertranS"
      server.vm.box = "ubuntu/bionic64"
      server.vm.network "private_network", ip: "192.168.56.110"
      server.vm.provider "virtualbox" do |vb|
        vb.name = "lbertranS"
        vb.memory = 512
        vb.cpus = 1
      end
      server.vm.provision "shell", inline: <<-SHELL
        curl -sfL https://get.k3s.io | sh -
  
        while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
          echo "Waiting for token generation..."
          sleep 5
        done
        cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token
      SHELL
    end
  
    config.vm.define "lbertranSW" do |worker|
      worker.vm.hostname = "lbertranSW"
      worker.vm.box = "ubuntu/bionic64"
      worker.vm.network "private_network", ip: "192.168.56.111"
      worker.vm.provider "virtualbox" do |vb|
        vb.name = "lbertranSW"
        vb.memory = 512
        vb.cpus = 1
      end
      worker.vm.provision "shell", inline: <<-SHELL
        while [ ! -f /vagrant/node-token ]; do
          echo "Waiting for token from server..."
          sleep 5
        done
  
        TOKEN=$(cat /vagrant/node-token)
        curl -sfL https://get.k3s.io | K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=$TOKEN sh -
      SHELL
    end
  end
  