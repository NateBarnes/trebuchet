module Trebuchet
  class Result
    attr_reader :failed_requests, :requests, :rps
    def initialize parse=nil
      @requests = 0
      @failed_requests = 0
      @rps = 0.0
      add_parse parse if parse
    end

    def add_parse parse
      @requests += parse.requests
      @failed_requests += parse.failed_requests
      @rps += parse.rps
    end

    def to_s
      "Requests: #{@requests}\nFailed Requests: #{@failed_requests}\nRequests Per Second: #{@rps}"
    end
  end
end
