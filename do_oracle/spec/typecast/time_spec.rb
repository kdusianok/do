# encoding: utf-8

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))
require 'data_objects/spec/typecast/time_spec'

describe 'DataObjects::Oracle with Time' do
  behaves_like 'supporting Time'
end

describe 'DataObjects::Oracle with Time' do

  setup_test_environment

  before do
    @connection = DataObjects::Connection.new(CONFIG.uri)
  end

  after do
    @connection.close
  end

  describe 'reading a Time' do

    describe 'with automatic typecasting' do

      before  do
        @reader = @connection.create_command("SELECT release_datetime FROM widgets WHERE ad_description = ?").execute_reader('Buy this product now!')
        @reader.next!
        @values = @reader.values
      end

      after do
        @reader.close
      end

      it 'should return the correctly typed result' do
        @values.first.should.be.kind_of(Time)
      end

      it 'should return the correct result' do
        @values.first.should == Time.local(2008, 2, 14, 00, 31, 12)
      end

    end

  end

end

describe 'DataObjects::Oracle session time zone' do

  after do
    @connection.close
  end

  describe 'set from environment' do

    before do
      pending "set TZ environment shell variable before running this test" unless ENV['TZ']
      @connection = DataObjects::Connection.new(CONFIG.uri)
    end

    it "should have time zone from environment" do
      @reader = @connection.create_command("SELECT sessiontimezone FROM dual").execute_reader
      @reader.next!
      @reader.values.first.should == ENV['TZ']
    end

  end

  describe "set with connection string option" do

    before do
      @connection = DataObjects::Connection.new(CONFIG.uri+"?time_zone=CET")
    end

    it "should have time zone from connection option" do
      @reader = @connection.create_command("SELECT sessiontimezone FROM dual").execute_reader
      @reader.next!
      @reader.values.first.should == 'CET'
    end

  end

end
