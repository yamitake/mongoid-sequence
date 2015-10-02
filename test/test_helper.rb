require "bundler/setup"
require "test/unit"
require "mongoid"

require File.expand_path("../../lib/mongoid-sequence", __FILE__)

Mongoid.load!("#{File.dirname(__FILE__)}/mongoid.yml", "test")
Mongo::Logger.logger.level = ::Logger::FATAL

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |f| require f }

class BaseTest < Test::Unit::TestCase
  def test_default; end # Avoid "No tests were specified." on 1.8.7

  def teardown
    Mongoid::Clients.default.database.collection_names.each do |c|
      Mongoid::Clients.default[c].drop
    end
  end

  def assert_sequence_value( name, value )
    sequence = Mongoid::Clients.default['__sequences'].where( :_id => name ).one
    assert_equal( value, sequence['seq'] )
  end
end