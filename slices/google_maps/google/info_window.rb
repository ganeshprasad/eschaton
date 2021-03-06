module Google
  
  class InfoWindow < MapObject
    attr_reader :object

    def initialize(options = {})
      # TODO - Find a better name than "object"
      @object = options.extract(:object)
      options[:var] = @object.var

      super
    end

    def open(options)     
      options.default! :location => :center, :include_location => true

      location = Google::OptionsHelper.to_location(options[:location])
      location = self.object.center if location == :center      

      if options[:url]
        options[:location] = location

        get(options) do |data|
          open_info_window_on_map :location => location, :content => data
        end        
      else
        text = Google::OptionsHelper.to_content options

        open_info_window_on_map :location => location, :content => text
      end
    end
    
    def open_on_marker(options)
      options.default! :include_location => true

      if options[:url]
        options[:location] = self.object.location

        get(options) do |data|
          open_info_window_on_marker :content => data
        end
      else
        text = OptionsHelper.to_content options

        open_info_window_on_marker :content => text
      end
    end

    private
      def window_content(content)
        "\"<div id='info_window_content'>\" + #{content.to_js} + \"</div>\""
      end

      def open_info_window_on_map(options)
        content = window_content options[:content]
        self << "#{self.var}.openInfoWindow(#{options[:location]}, #{content});"        
      end

      def open_info_window_on_marker(options)
        content = window_content options[:content]
        self << "#{self.var}.openInfoWindow(#{content});"
      end

      def get(options)
        if options[:include_location] == true
          options[:url][:location] = Google::UrlHelper.encode_location(options[:location])
        end

        self.script.get(options[:url]) do |data|
          yield data
        end
      end

  end
end