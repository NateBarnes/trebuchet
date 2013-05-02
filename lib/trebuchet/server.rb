module Trebuchet
  class Server
    attr_accessor :config, :connection, :instances, :siege_config

    def initialize config=nil
      @config = config || YAML::load(File.open('trebuchet.yml'))
      @siege_config = { :concurrency => 1, :url => "http://www.example.com", :time => "1M" }
      @connection = Fog::Compute.new(:provider => "AWS", :aws_access_key_id => @config.fetch("aws-config", {}).fetch("access_key_id"), :aws_secret_access_key => @config.fetch("aws-config", {}).fetch("access_key_secret"))
      refresh_instances
    end

    def start num_of_servers=1
      puts "Starting #{num_of_servers} servers!"
      num_of_servers.times do
        @connection.servers.bootstrap(:public_key_path => '~/.ssh/id_rsa.pub', :username => 'ubuntu', :tags => {:temporary => true}) rescue Net::SSH::Disconnect
      end
      puts "#{num_of_servers} Servers Started!"

      refresh_instances
      puts "There are currently #{@instances.count} running instances"
      puts "Setting up new instances!"
      @instances.each { |instance| setup_instance instance }
      puts "New instances configured and ready for use!"
    end

    def stop_all
      @instances.each { |instance| instance.destroy }
    end

    def run
      puts "Beginning Load Test"
      @instances.each { |instance| run_siege instance }

      nil
    end

private
    def refresh_instances
      @instances = @connection.servers.select { |instance| instance.tags.fetch("temporary", false) and instance.state == "running" }
    end

    def setup_instance instance
      ssh = Net::SSH.start(instance.dns_name, "ubuntu")
      res = ssh.exec! "sudo apt-get install siege"
      ssh.close
    end

    def run_siege instance
      ssh = Net::SSH.start(instance.dns_name, "ubuntu")
      cmd = "siege -c #{run_concurrency} -t #{run_time} #{run_url}"
      puts "Executing Command: #{cmd}"
      res = ssh.exec! cmd
      ssh.close
      puts ""
      puts "Instance #{instance.dns_name} Completed:"
      puts res
      puts ""
    end

    def run_concurrency
      @siege_config.fetch :concurrency, 1
    end

    def run_time
      @siege_config.fetch :time, "1M"
    end

    def run_url
      @siege_config.fetch(:url, "http://localhost")
    end
  end
end

