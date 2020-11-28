class Asteroid
  def initialize(info)
    @name = info[:name]
    @diameter = info[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    @miss_distance = info[:close_approach_data][0][:miss_distance][:miles].to_i
  end
end
