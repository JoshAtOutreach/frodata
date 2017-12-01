module OData
  # ComplexTypes are used in OData to either encapsulate richer data types for
  # use as Entity properties. ComplexTypes are composed of properties the same
  # way that Entities are and, so, the interface for working with the various
  # properties of a ComplexType mimics that of Entities.
  class ComplexType
    # The name of the ComplexType
    attr_reader :name

    # Creates a new ComplexType based on the supplied options.
    # @param options [Hash]
    # @return [self]
    def initialize(options = {})
      validate_options(options)

      @name = options[:name].to_s
      @service = options[:service]

      collect_properties
    end

    # Returns the namespaced type for the ComplexType.
    # @return [String]
    def type
      "#{namespace}.#{name}"
    end

    # Returns the namespace this ComplexType belongs to.
    # @return [String]
    def namespace
      @namespace ||= service.namespace
    end

    # Returns a list of this ComplexType's property names.
    # @return [Array<String>]
    def property_names
      @property_names ||= properties.collect {|name, property| name}
    end

    # Returns the value of the requested property.
    # @param property_name [to_s]
    # @return [*]
    def [](property_name)
      properties[property_name.to_s].value
    end

    # Sets the value of the named property.
    # @param property_name [to_s]
    # @param value [*]
    # @return [*]
    def []=(property_name, value)
      properties[property_name.to_s].value = value
    end

    # Returns the XML representation of the property to the supplied XML
    # builder.
    # @param xml_builder [Nokogiri::XML::Builder]
    def to_xml(xml_builder)
      attributes = {
          'metadata:type' => type,
      }

      xml_builder['data'].send(name.to_sym, attributes) do
        properties.each do |name, property|
          property.to_xml(xml_builder)
        end
      end
    end

    private

    def service
      @service
    end

    def properties
      @properties
    end

    def validate_options(options)
      raise ArgumentError, 'Name is required' unless options[:name]
      raise ArgumentError, 'Service is required' unless options[:service]
      raise ArgumentError, 'Not a ComplexType' unless options[:service].complex_types.include? options[:name]
    end

    def collect_properties
      @properties = service.properties_for_complex_type(name)
    end
  end
end
