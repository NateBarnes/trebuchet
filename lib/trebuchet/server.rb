module Trebuchet
  class Server
    attr_accessor :config, :connection, :instances

    def initialize config=nil
      @config = config || YAML::load(File.open('trebuchet.yml'))
      @connection = Fog::Compute.new(:provider => "AWS", :aws_access_key_id => @config.fetch("aws-config", {}).fetch("access_key_id"), :aws_secret_access_key => @config.fetch("aws-config", {}).fetch("access_key_secret"))
      refresh_instances
    end

    def start num_of_servers=1
      num_of_servers.times do
        @connection.servers.bootstrap(:public_key_path => '~/.ssh/id_rsa.pub', :username => 'ubuntu', :tags => {:temporary => true}) rescue Net::SSH::Disconnect
      end

      refresh_instances
    end

    def stop num_of_servers

    end

    def stop_all
      @instances.each { |instance| instance.destroy }
    end

    def refresh_instances
      @instances = @connection.servers.select { |instance| instance.tags.fetch("temporary", false) and instance.state == "running" }
    end
  end
end
