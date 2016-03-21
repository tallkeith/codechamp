require "pry"
require "httparty"
require "json"
require "codechamp/version"

module Codechamp
  class App
    include HTTParty
    base_uri "https://api.github.com"

    
  end
end

