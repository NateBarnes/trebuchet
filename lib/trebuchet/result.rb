module Trebuchet
  class Result
    def initialize parse=nil
      @requests = 0
      @failed_requests = 0
      @rps = 0.0
      add_parse parse if parse
    end

    def add_parse parse
      @requests = requests + parse.requests
      @failed_requests = failed_requests + parse.failed_requests
      @rps = rps + parse.rps
    end

    def to_s
      "Requests: #{@requests}\nFailed Requests: #{@failed_requests}\nRequests Per Second: #{@rps}"
    end

    def requests
      @requests || 0
    end

    def failed_requests
      @failed_requests || 0
    end

    def rps
      @rps || 0
    end
  end
end
