module Google
  
  # Represents a marker that can be added to a Map. If a method or event is not documented here please 
  # see googles online[http://code.google.com/apis/maps/documentation/reference.html#GMarker] docs for details.
  #
  # You will most likely use click and open_info_window to get some basic functionality going.
  #
  # Examples:
  #
  #  Google::Marker.new(:location => {:latitude => -34, :longitude => 18.5})
  #  
  #  Google::Marker.new(:location => {:latitude => -34, :longitude => 18.5}, 
  #                     :draggable => true,
  #                     :title => "This is a marker!")
  class Marker < MapObject
    attr_accessor :icon
    attr_reader :location
    
    # Options:
    # :location:: => Required. A Location or whatever Location#new supports which indicates where the marker must be placed on the map.
    # :icon::     => Optional. The Icon that should be used for the marker otherwise the default marker icon will be used.
    #
    # See addtional options[http://code.google.com/apis/maps/documentation/reference.html#GMarkerOptions] that are supported.
    def initialize(options = {})
      options.default! :var => 'marker'
      
      super
                  
      if create_var?
        @location = options.extract_and_remove(:location).to_location

        if icon = options.extract_and_remove(:icon)
          self.icon = icon.to_icon
          options[:icon] = self.icon
        end

        self << "#{self.var} = new GMarker(#{self.location}, #{options.to_google_options});"
      end
    end
    
    def change_image(image)
      self << "#{self.var}.setImage('#{image}');"
    end
    
    # Opens an info window that contains a blowup view of the map around this marker.
    #
    # Options:
    # :zoom_level => Optional. Sets the blowup to a particular zoom level.
    # :map_type   => Optional. Set the type of map shown in the blowup.
    def show_map_blowup(options = {})
     options[:map_type] = options[:map_type].to_map_type if options[:map_type]

     self << "#{self.var}.showMapBlowup(#{options.to_google_options})" 
    end
    
    # Opens a information window on the marker. Either a +url+ or +text+ option can be supplied to place 
    # within the info window.
    #
    # :url::     => Optional. URL is generated by rails #url_for. Supports standard url arguments and javascript variable interpolation.
    # :partial:: => Optional. Supports the same form as rails +render+ for partials, content of the rendered partial will be placed inside the info window.
    # :text::    => Optional. The html content that will be placed inside the info window. 
    def open_info_window(options)      
      if options[:url]
        self.script.get(options[:url]) do |data|
          self << "#{self.var}.openInfoWindow(#{data});"
        end
      else
        text = if options[:partial]
                 Eschaton.current_view.render options
               else
                 options[:text]
               end

        self << "#{self.var}.openInfoWindow(#{text.to_js});"
      end
    end

    # If called with a block it will attach the block to the "click" event of the marker.
    # If +info_window_options+ are supplied an info window will be opened with those options and the block will be ignored.
    #
    # :yields :script
    def click(info_window_options = nil, &block)
      if info_window_options
        self.click do
          self.open_info_window info_window_options
        end
      elsif block_given?
        self.listen_to :event => :click, &block        
      end
    end
    
    def when_drag_starts(&block)
      self.listen_to :event => :dragstart, &block
    end
    
    def when_drag_ends(&block)
      self.listen_to :event => :dragend, :with => [:location] do |*args|
        script = args.first               
        script << "location = #{self.var}.getLatLng();"

        yield *args
      end
    end
    
    def to_marker
      self
    end
    
  end
end