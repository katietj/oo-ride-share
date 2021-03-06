require_relative 'spec_helper'

describe "User class" do

  describe "User instantiation" do
    before do
      @user = RideShare::User.new(id: 1, name: "Smithy", phone: "353-533-5334")
    end

    it "is an instance of User" do
      expect(@user).must_be_kind_of RideShare::User
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::User.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@user.trips).must_be_kind_of Array
      expect(@user.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@user).must_respond_to prop
      end

      expect(@user.id).must_be_kind_of Integer
      expect(@user.name).must_be_kind_of String
      expect(@user.phone_number).must_be_kind_of String
      expect(@user.trips).must_be_kind_of Array
    end
  end

  describe "User Aggregate Statistics" do
    before do
      @user = RideShare::User.new(id: 9, name: "Merl Glover III",
      phone: "1-602-620-2330 x3723", trips: [])
    end
    it "calculates total of money user spent" do
      trip_1 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      trip_2 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      trip_3 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      @user.add_trip(trip_1)
      @user.add_trip(trip_2)
      @user.add_trip(trip_3)
      expect(@user.net_expenditures).must_equal (10 + 10 + 10)
    end

    it "calculates total trip time" do
      trip_1 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      trip_2 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      trip_3 = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      cost: 10, rating: 5)
      @user.add_trip(trip_1)
      @user.add_trip(trip_2)
      @user.add_trip(trip_3)
      expect(@user.total_time_spent).must_equal (24*60*60*3)
    end
  end



  describe "trips property" do
    before do
      @user = RideShare::User.new(id: 9, name: "Merl Glover III",
      phone: "1-602-620-2330 x3723", trips: [])
      trip = RideShare::Trip.new(id: 8, driver: nil, passenger: @user,
      start_time: Time.parse("2016-08-08"),
      end_time: Time.parse("2016-08-09"),
      rating: 5)

      @user.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @user.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's user id" do
      @user.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end
end
