module Google

  class Location < MapObject
  
    attr_reader :latitude, :longitude
  
    # :latitude, :longitude
    def initialize(options)
      super
      
      @longitude, @latitude = options[:longitude], options[:latitude]
    
      script << "new GLatLng(#{self.latitude}, #{self.longitude})"
    end
    
    # This method provides compatibility with Hash#to_location and in this case returns self.
    def to_location
      self
    end
  
  end
  
end