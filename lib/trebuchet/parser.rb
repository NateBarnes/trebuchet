module Trebuchet
  class Parser
    attr_reader :failed_requests, :requests, :rps
    def initialize siege_result
      parse siege_result
    end

  private
    def parse result
      data_lines = result.lines.to_a[4..-1]
      data_lines.each do |line|
        method = "parse_#{line.split(":").first}".downcase.gsub(" ", "_")
        send(method, line.split(":").last) if private_methods.include? method.to_sym
      end
    end

    def parse_transactions data
      @requests = Integer(data.match(/\d+/)[0])
    end

    def parse_failed_transactions data
      @failed_requests = Integer(data.match(/\d+/)[0])
    end

    def parse_transaction_rate data
      @rps = data.match(/[-+]?[0-9]*\.?[0-9]+/)[0].to_f
    end
  end
end
