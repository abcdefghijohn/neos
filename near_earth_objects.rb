require 'faraday'
require 'figaro'
require 'pry'
require 'json'
require_relative 'asteroid'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects
  def initialize(date)
    @date = date
    @asteroid_data = parsed_asteroids_data
  end

  def connect
    Faraday.new(
      url: 'https://api.nasa.gov',
      params: { start_date: @date, api_key: ENV['nasa_api_key']}
    )
  end

  def find_neos_by_date
    {
      asteroid_list: formatted_asteroid_data,
      biggest_asteroid: largest_asteroid_diameter,
      total_number_of_asteroids: total_number_of_asteroids
    }
  end

  def parsed_asteroids_data
    asteroids_list_data = connect.get('/neo/rest/v1/feed')

    JSON.parse(asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{@date}"]
  end

  def formatted_asteroid_data
    @asteroid_data.map do |asteroid|
      {
       name: asteroid[:name],
       diameter: "#{asteroid_diameter(asteroid)} ft",
       miss_distance: "#{asteroid_miss_distance(asteroid)} miles"
       }
     end
  end

  def asteroid_diameter(asteroid)
    asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
  end

  def asteroid_miss_distance(asteroid)
    asteroid[:close_approach_data][0][:miss_distance][:miles].to_i
  end

  def largest_asteroid_diameter
    @asteroid_data.max do |asteroid_a, asteroid_b|
      asteroid_diameter(asteroid_a) <=> asteroid_diameter(asteroid_b)
    end
  end

  def total_number_of_asteroids
    @asteroid_data.count
  end
  # def self.find_neos_by_date(date)
  #   conn = Faraday.new(
  #     url: 'https://api.nasa.gov',
  #     params: { start_date: date, api_key: ENV['nasa_api_key']}
  #   )
  #   asteroids_list_data = conn.get('/neo/rest/v1/feed')
  #
  #   parsed_asteroids_data = JSON.parse(asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{date}"]
  #
  #   largest_asteroid_diameter = parsed_asteroids_data.map do |asteroid|
  #     asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
  #   end.max { |a,b| a<=> b}
  #
  #   total_number_of_asteroids = parsed_asteroids_data.count
  #   formatted_asteroid_data = parsed_asteroids_data.map do |asteroid|
  #     {
  #       name: asteroid[:name],
  #       diameter: "#{asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
  #       miss_distance: "#{asteroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
  #     }
  #   end

  #   {
  #     asteroid_list: formatted_asteroid_data,
  #     biggest_asteroid: largest_asteroid_diameter,
  #     total_number_of_asteroids: total_number_of_asteroids
  #   }

end
