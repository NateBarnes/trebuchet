module Trebuchet
  class Server
    attr_accessor :concurrency, :config, :connections, :instances, :result, :time, :url

    def initialize config=nil
      if File.exists?("trebuchet.yml")
        file = File.open('trebuchet.yml')
      elsif File.exists?("~/.trebuchet")
        file = File.open("~/.trebuchet")
      end
      @config = config || YAML::load(file)
      @concurrency = "1"
      @time = "1M"
      @url = "http://www.example.com"
      regions = @config.fetch("aws-config", {}).fetch("regions", ["us-east-1"])

      @connections = []
      regions.each do |region|
        @connections << Fog::Compute.new(:provider => "AWS", :aws_access_key_id => @config.fetch("aws-config", {}).fetch("access_key_id"), :aws_secret_access_key => @config.fetch("aws-config", {}).fetch("access_key_secret"), :region => region)
      end

      refresh_instances
    end

    def start num_of_servers=1
      puts "Starting #{num_of_servers} servers!"
      futures = []
      num_of_servers.times do
        futures << Celluloid::Future.new do
          @connections.sample.servers.bootstrap(:public_key_path => '~/.ssh/id_rsa.pub', :username => 'ubuntu', :tags => {:temporary => true}) rescue Net::SSH::Disconnect
        end
      end
      futures.each { |future| future.value }
      puts "#{num_of_servers} Servers Started!"

      refresh_instances

      puts "Setting up new instances!"
      @instances.each { |instance| setup_instance instance }

      puts "New instances configured and ready for use!"
    end

    def stop
      puts "Shutting down all instances"
      @instances.each { |instance| instance.destroy }
      refresh_instances
    end

    def run
      puts "Beginning Load Test"
      @result = Trebuchet::Result.new
      futures = []
      @instances.each do |instance|
        futures << Celluloid::Future.new { run_siege instance }
      end
      futures.each { |future| future.value }
      puts @result.to_s

      nil
    end

private
    def refresh_instances
      @instances = []
      @connections.each do |connection|
        new_instance = connection.servers.select { |instance| instance.tags.fetch("temporary", false) and instance.state == "running" }
        @instances << new_instance unless new_instance.empty?
      end
      @instances.flatten!

      nil
    end

    def setup_instance instance
      ssh = Net::SSH.start(instance.dns_name, "ubuntu")
      ssh.exec! "sudo apt-get install siege"
      ssh.exec! %{echo "verbose = false" > ~/.siegerc}
      ssh.exec! %{sudo sh -c "echo '*               hard    nofile            1000000' >> /etc/security/limits.conf"}
      ssh.exec! %{sudo sh -c "echo '*               soft    nofile            1000000' >> /etc/security/limits.conf"}
      ssh.close
    end

    def run_siege instance
      ssh = Net::SSH.start(instance.dns_name, "ubuntu")
      cmd = "siege -R ~/.siegerc -c #{concurrency} -t #{time} #{url}"
      res = ssh.exec! cmd
      ssh.close
      parse = Trebuchet::Parser.new(res)
      @result.add_parse(parse)
    end
  end
end

