
module Codechamp
  class Github
    include HTTParty
    base_uri "https://api.github.com"

    def initialize(token)
    	@headers = {
    		"Authorization" => "token #{token}",
    		"User-Agent" => "HTTParty"
    	}
    end

    def get_contributions(owner, repo)
    	Github.get('/repos/#{owner}/#{repo}/stats/conributors', headers: @headers)
    end
  end
end
