module Trebuchet
  class Server
    attr_accessor :config, :instances

    def initialize config=nil
      @config = config || YAML::load(File.open('trebuchet.yml'))
    end

    def start num_of_servers

    end
  end
end
