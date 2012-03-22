require 'minitest_helper'

describe Polygon do
  describe "#new" do
    it "should return a polygon object" do
      @it = Polygon.new
      assert_equal Polygon, @it.class
    end

    it "should return a polygon with a cartodb_id" do
      @it = Polygon.new({:cartodb_id => 1234})
      assert_equal 1234, @it.cartodb_id
    end
  end

  describe "#find" do
    before do
      @cartodb_id = 1234
      @cartodb_polygon = {:cartodb_id => @cartodb_id}

      @cartodb_connection = MiniTest::Mock.new
      @cartodb_connection.expect(:row, @cartodb_polygon, [Object, Integer])

      CartoDB::Connection = @cartodb_connection

      @it = Polygon.find(@cartodb_id)
    end

    after do
      @cartodb_connection.verify
    end

    it "should return an object with the cartodb_id" do
      assert_equal @cartodb_id, @it.cartodb_id
    end
  end

  describe "#save" do
    before do
      @polygon_name = "Name1"
      @cartodb_polygon = { :name => @polygon_name }
      @cartodb_connection = MiniTest::Mock.new
      @cartodb_connection.expect(:insert_row, @cartodb_polygon, [Object, Hash])

      CartoDB::Connection = @cartodb_connection

      @it = Polygon.new(@cartodb_polygon).save
    end

    after do 
      @cartodb_connection.verify
    end

    it "should return the saved object similar to @cartodb_polygon" do
      assert_equal @cartodb_polygon[:name], @it[:name]
    end
  end

  describe "#attributes" do
    it "returns an hash" do
      polygon = Polygon.new
      assert_equal true, polygon.attributes.is_a?(Hash)
    end
  end
end
