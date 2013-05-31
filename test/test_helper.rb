$LOAD_PATH.push File.expand_path("../lib", File.dirname(__FILE__))

unless defined?(Bundler)
  require 'rubygems'
end

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
end

require 'test/unit'
require 'clerk'
