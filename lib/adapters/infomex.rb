require 'mechanize'
require 'httparty'

module Bazooka

  module Infomex
    @config = {}

    def setup sistemas
      @config = {}
      sistemas.each do |stub, data|
        @config[stub] = Sistema.new(data)
      end
    end

    def [] stub
      @config[stub]
    end
  end
end
