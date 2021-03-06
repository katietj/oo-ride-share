require 'csv'
require 'time'
require 'pry'

require_relative 'user'
require_relative 'trip'
require_relative 'driver'



module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips
    attr_writer :passengers

    def initialize(user_file = 'support/users.csv',
      trip_file = 'support/trips.csv',
      driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)

    end

    def request_trip(user_id)
      passenger = find_passenger(user_id)
      driver = @drivers.find{|driver| driver.status == :AVAILABLE && driver.id != user_id}
      raise ArgumentError.new "no drivers!" if driver == nil
      parsed_trip = {
        id: @trips.last.id + 1,
        driver: driver,
        passenger: passenger,
        start_time: Time.now,
        end_time: nil,
        cost: nil,
        rating: nil
      }
      new_trip = Trip.new(parsed_trip)
      @trips << new_trip

      driver.add_driven_trip(new_trip)
      passenger.add_trip(new_trip)
      driver.driver_on_trip
      return new_trip
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
      header_converters: :symbol)

      trip_data.each do |raw_trip|
        passenger = find_passenger(raw_trip[:passenger_id].to_i)
        driver = find_driver(raw_trip[:driver_id].to_i)

        parsed_trip = {
          id: raw_trip[:id].to_i,
          driver: driver,
          passenger: passenger,
          start_time: Time.parse(raw_trip[:start_time]),
          end_time: Time.parse(raw_trip[:end_time]),
          cost: raw_trip[:cost].to_f,
          rating: raw_trip[:rating].to_i
        }

        trip = Trip.new(parsed_trip)
        trips << trip

        passenger.add_trip(trip)
        driver.add_driven_trip(trip)

      end
      return trips
    end

    def load_drivers(filename)
      driver_data = CSV.open(filename, 'r', headers: true,
      header_converters: :symbol)

      return driver_data.map do |raw_driver|
        user = find_passenger(raw_driver[:id].to_i)

        parse_driver = {
          id: raw_driver[:id].to_i,
          name: user.name,
          phone: user.phone_number,
          trips: user.trips,
          vin: raw_driver[:vin],
          status: raw_driver[:status].to_sym,
        }

        Driver.new(parse_driver)
      end
    end

    def find_driver(id)
      check_id(id)
      return @drivers.find { |driver| driver.id == id }
    end

    def find_passenger(id)
      check_id(id)
      return @passengers.find { |passenger| passenger.id == id }
    end

    def inspect
      return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
      #{trips.count} trips, \
      #{drivers.count} drivers, \
      #{passengers.count} passengers>"
    end

    private

    def check_id(id)
      raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
    end
  end
end
