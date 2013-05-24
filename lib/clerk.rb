require 'active_support'
require 'active_support/dependencies'
require 'active_model'
ActiveSupport::Dependencies.autoload_paths += %w(clerk) 

module Clerk 
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :ResultSet
  autoload :Transformations
  autoload :Template
end
