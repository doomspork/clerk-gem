#require 'test/unit'
#require 'clerk/transformations'
#
#class ClerkSample < Clerk::Base
#  template do |t| 
#    t.named :a
#    t.grouped :group_name do |group|
#      group.named :group_a
#      group.named :group_b
#    end
#  end
#end
#
#class TestClerkTransformations < Test::Unit::TestCase
#  def setup
#    @clerk = ClerkSample.new
#  end
#  
#  def test_transform_with_helper
#    upcaser = Class.new do 
#      def transform(value)
#        value.upcase
#      end
#    end
#
#    @clerk.class.transform_with upcaser, :a
#    @clerk.load %w(a ga gb)
#    @clerk.
#  end
#end
