require_relative 'near_earth_objects'

class StartTable
  def initialize
    @date = ""
  end

  def start
    get_date
    output_data
  end

  def initial_message
    puts "________________________________________________________________________________________________________________________________"
    puts "Welcome to NEO. Here you will find information about how many meteors, asteroids, comets pass by the earth every day. \nEnter a date below to get a list of the objects that have passed by the earth on that day."
    puts "Please enter a date in the following format YYYY-MM-DD."
    print ">>"
  end

  def get_date
    initial_message
    @date = gets.chomp
  end

  def formatted_date
    DateTime.parse(@date).strftime("%A %b %d, %Y")
  end

  def asteroid_details
    NearEarthObjects.new(@date).find_neos_by_date
  end

  def asteroid_list
    asteroid_details[:asteroid_list]
  end

  def total_number_of_asteroids
    asteroid_details[:total_number_of_asteroids]
  end

  def largest_asteroid
    asteroid_details[:biggest_asteroid]
  end

  def column_labels
    { name: "Name", diameter: "Diameter", miss_distance: "Missed The Earth By:" }
  end

  def column_data
    column_labels.each_with_object({}) do |(col, label), hash|
      hash[col] = {
        label: label,
        width: [asteroid_list.map { |asteroid| asteroid[col].size }.max, label.size].max}
    end
  end

  def header
    "| #{ column_data.map { |_,col| col[:label].ljust(col[:width]) }.join(' | ') } |"
  end

  def divider
    "+-#{column_data.map { |_,col| "-"*col[:width] }.join('-+-') }-+"
  end

  def format_row_data(row_data, column_info)
    row = row_data.keys.map { |key| row_data[key].ljust(column_info[key][:width]) }.join(' | ')
    puts "| #{row} |"
  end

  def create_rows(asteroid_data, column_info)
    rows = asteroid_data.each { |asteroid| format_row_data(asteroid, column_info) }
  end

  def output_data
    puts "______________________________________________________________________________"
    puts "On #{formatted_date}, there were #{total_number_of_asteroids} objects that almost collided with the earth."
    puts "The largest of these was #{largest_asteroid} ft. in diameter."
    puts "\nHere is a list of objects with details:"
    puts divider
    puts header
    create_rows(asteroid_list, column_data)
    puts divider
  end
end
