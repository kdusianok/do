require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'data_objects', 'support', 'pooling')
require 'timeout'

describe "Object::Pooling" do

  before(:all) do
    class Thing
      include Object::Pooling

      attr_accessor :name

      def initialize(name)
        @name = name
      end

      def dispose
        @name = nil
      end
    end
  end

  it "has a default max pool size" do
    Thing::pools.size.should == 4
  end

  it "blocks aquiring when pool size limit is hit" do
    pending

    # default size is 4
    Thing.new('Grumpy')
    Thing.new('Grumpy')
    Thing.new('Grumpy')
    Thing.new('Grumpy')

    thread = Thread.new { Thing.new('Grumpy') }

    lambda do
      Timeout::timeout(1) { thread.join }
    end.should raise_error(Timeout::Error)

    Thing::pools.flush!
  end

  it "should respond to ::new and #release" do
    Thing.should respond_to(:new)
    Thing.instance_methods.should include("release")
  end

  it "raises an error on initialization if the target object doesn't implement a `dispose' method" do
    lambda do
      class Durian
        include Object::Pooling
      end.new
    end.should raise_error(Object::Pooling::MustImplementDisposeError)
  end

  it "is able to aquire an object when pool size limit is not hit yet" do
    bob = Thing.new("bob")
    bob.name.should == 'bob'

    fred = Thing.new("fred")
    fred.name.should == 'fred'

    Thing::pools['bob'].reserved.should have(1).entries
    Thing::pools['bob'].available.should have(0).entries

    Thing::pools['fred'].reserved.should have(1).entries
    Thing::pools['fred'].available.should have(0).entries

    bob2 = Thing.new("bob")
    bob2.name.should == 'bob'

    Thing::pools['bob'].reserved.should have(2).entries
    Thing::pools['bob'].available.should have(0).entries

    bob.release
    Thing::pools['bob'].available.should have(1).entries
    Thing::pools['bob'].reserved.should have(1).entries

    bob2.release
    Thing::pools['bob'].available.should have(2).entries
    Thing::pools['bob'].reserved.should have(0).entries

    fred.release
  end

  it "should allow you to flush an individual pool" do
    Thing.new('fred')

    Thing::pools['fred'].reserved.should have(1).entries

    Thing::pools['fred'].flush!

    Thing::pools['fred'].reserved.should have(0).entries
    Thing::pools['fred'].available.should have(0).entries
  end

  it "should allow you to flush all pools at once" do
    Thing.new('fred')
    Thing.new('bob')

    Thing::pools['fred'].reserved.should have(1).entries
    Thing::pools['bob'].reserved.should have(1).entries

    Thing::pools.flush!
    Thing::pools['fred'].reserved.should have(0).entries
    Thing::pools['bob'].reserved.should have(0).entries
  end


  it "should dispose idle available objects"
end
