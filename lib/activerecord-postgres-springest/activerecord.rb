require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  class ArrayTypeMismatch < ActiveRecord::ActiveRecordError
  end

  class Base
    def arel_attributes_values(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
      attrs      = {}
      klass      = self.class
      arel_table = klass.arel_table

      attribute_names.each do |name|
        if (column = column_for_attribute(name)) && (include_primary_key || !column.primary)
          if include_readonly_attributes || !self.class.readonly_attributes.include?(name)
            value = read_attribute(name)
            if column.type.to_s =~ /_array$/ && value && value.is_a?(Array)
              value = value.to_postgres_array(new_record?)
            elsif klass.serialized_attributes.include?(name)
              value = @attributes[name].serialized_value
            end
            attrs[arel_table[name]] = value
          end
        end
      end

      attrs
    end
  end

  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      POSTGRES_ARRAY_TYPES = %w( string text integer float decimal datetime timestamp time date binary boolean inet macaddr cidr )

      def native_database_types_with_patch(*args)
        native_database_types_without_patch.merge!(
          {
          inet:        { name: "inet" },
          cidr:        { name: "cidr" },
          macaddr:     { name: "macaddr" },
          }
        )
        native_database_types_without_patch.merge(POSTGRES_ARRAY_TYPES.inject(Hash.new) {|h, t| h.update("#{t}_array".to_sym => {:name => "#{native_database_types_without_patch[t.gsub("_array", "").to_sym][:name]}[]"})})
      end
      alias_method_chain :native_database_types, :patch

      # Quotes a value for use in an SQL statement
      def quote_with_array(value, column = nil)
        if value && column && column.sql_type =~ /\[\]$/
          raise ArrayTypeMismatch, "#{column.name} must be an Array or have a valid array value (#{value})" unless value.kind_of?(Array) || value.valid_postgres_array?
          return value.to_postgres_array
        end
        quote_without_array(value,column)
      end
      alias_method_chain :quote, :array
    end

    class Table
      # Adds array type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.string_array :real_energy
      #     t.decimal_array :real_energy, :precision => 18, :scale => 6
      #     ...
      #   end
      PostgreSQLAdapter::POSTGRES_ARRAY_TYPES.each do |column_type|
        define_method("#{column_type}_array") do |*args|
          options = args.extract_options!
          base_type = @base.type_to_sql(column_type.to_sym, options[:limit], options[:precision], options[:scale])
          column_names = args
          column_names.each { |name| column(name, "#{base_type}[]", options) }
        end
      end

      def inet(name, options = {})
        column(name, 'inet', options)
      end

      def cidr(name, options = {})
        column(name, 'cidr', options)
      end

      def macaddr(name, options = {})
        column(name, 'macaddr', options)
      end
    end

    class TableDefinition
      # Adds array type for migrations. So you can add columns to a table like:
      #   create_table :people do |t|
      #     ...
      #     t.string_array :real_energy
      #     t.decimal_array :real_energy, :precision => 18, :scale => 6
      #     ...
      #   end
      PostgreSQLAdapter::POSTGRES_ARRAY_TYPES.each do |column_type|
        define_method("#{column_type}_array") do |*args|
          options = args.extract_options!
          base_type = @base.type_to_sql(column_type.to_sym, options[:limit], options[:precision], options[:scale])
          column_names = args
          column_names.each { |name| column(name, "#{base_type}[]", options) }
        end
      end

      def inet(name, options = {})
        column(name, 'inet', options)
      end

      def cidr(name, options = {})
        column(name, 'cidr', options)
      end

      def macaddr(name, options = {})
        column(name, 'macaddr', options)
      end
    end

    class PostgreSQLColumn < Column
      def self.string_to_cidr(string)
        if string.blank?
          nil
        else
          string
        end
      end

      def self.cidr_to_string(object)
        if object.blank?
          nil
        elsif IPAddr === object
          "#{object.to_s}/#{object.instance_variable_get(:@mask_addr).to_s(2).count('1')}"
        else
          object
        end
      end

      # Does the type casting from array columns using String#from_postgres_array or Array#from_postgres_array.
      def type_cast_code_with_patch(var_name)
        klass = self.class.name
        case type
          when /array$/
            base_type = type.to_s.gsub(/_array/, '')
            "#{var_name}.from_postgres_array(:#{base_type.parameterize('_')})"
          when :inet, :cidr
             "#{klass}.cidr_to_string(#{var_name})"
          else
            type_cast_code_without_patch(var_name)
        end
      end
      alias_method_chain :type_cast_code, :patch

      # Used for defaults
      def type_cast_with_patch(value)
        klass = self.class

        if value.present? && type.to_s =~ /_array$/
          base_type = type.to_s.gsub(/_array/, '')
          value.from_postgres_array(base_type.parameterize('_').to_sym)

        elsif value.present? && type.to_s =~ /(inet|cidr)/
          klass.string_to_cidr(value)
        else
          type_cast_without_patch(value)
        end
      end
      alias_method_chain :type_cast, :patch

      # Adds the array type for the column.
      def simplified_type_with_patch(field_type)
        case field_type
          when 'inet'
            :inet
          when 'cidr'
            :cidr
          when 'macaddr'
            :macaddr
          when /^numeric.+\[\]$/
            :decimal_array
          when /character varying.*\[\]/
            :string_array
          when /^(?:real|double precision)\[\]$/
            :float_array
          when /timestamp.*\[\]/
            :timestamp_array
          when /\[\]$/
            field_type.gsub(/\[\]/, '_array').to_sym
          else
            simplified_type_without_patch(field_type)
        end
      end
      alias_method_chain :simplified_type, :patch
    end
  end
end
