module HasArrayField
  extend ActiveSupport::Concern

  class_methods do
    def has_array_field(accessor_name, klass=nil)
      klass ||= accessor_name.to_s.singularize.capitalize.constantize
      column_name = "#{accessor_name.to_s.singularize}_ids".to_sym

      define_method(accessor_name) do
        _get_ary_accessor(column_name, klass)
      end

      define_method("#{accessor_name}=") do |vals|
        _set_ary_vals(column_name, klass, vals)
      end

      define_method("#{column_name}=") do |ids|
        @_array_accessors ||= {}
        @_array_accessors[column_name] = nil
        super(ids)
      end

      define_method("reload") do |*args|
        @_array_accessors = {}
        super(*args)
      end
    end
  end

  def _get_ary_accessor(column_name, klass)
    @_array_accessors ||= {}
    @_array_accessors[column_name] ||= ArrayFieldAccessor.new(self, column_name, klass)
  end

  def _set_ary_vals(column_name, klass, vals)
    @_array_accessors ||= {}
    new_vals = vals.to_a.flatten.compact.select{|v| v.kind_of?(klass) and v.persisted?}
    self.send("#{column_name}=", new_vals.map(&:id))
    @_array_accessors[column_name] = ArrayFieldAccessor.new(self, column_name, klass, new_vals)
    new_vals
  end

  class ArrayFieldAccessor
    def initialize(on_obj, column_name, klass, records=nil)
      @on_obj = on_obj
      @column_name = column_name
      @klass = klass
      @loaded = !!records
      @records = records
    end

    def base_query
      @klass.where(id: @on_obj.send(@column_name))
    end

    def push(*objs)
      if @loaded
        @on_obj._set_ary_vals(@column_name, @klass, (@records+objs))
      else
        record_ids = @on_obj.send(@column_name)
        @on_obj.send("#{@column_name}=", record_ids+(objs.map(&:id)))
      end
      true # to prevent chaining
    end
    alias << push

    def delete(obj)
      if @loaded
        @on_obj._set_ary_vals(@column_name, @klass, (@records-[obj]))
      else
        record_ids = @on_obj.send(@column_name)
        @on_obj.send("#{@column_name}=", (record_ids-[obj.id]))
      end
      true
    end

    def inspect
      if @loaded
        @records.inspect
      else
        base_query.inspect
      end
    end

    def method_missing(name, *args, &block)
      result = nil

      if @loaded
        # Try running method against loaded Array.
        if @records.respond_to? name
          result = @records.send(name, *args, &block)
        else
          result = base_query.send(name, *args, &block)
        end
      else
        if [].respond_to?(name) and not name.to_sym == :first
          # Load records now.
          @records = base_query.send(:to_a)
          @loaded = true
          result = @records.send(name, *args, &block)
        else
          # Proxy response to base_query.
          result = base_query.send(name, *args, &block)
        end
      end

      result
    end

  end
end

ActiveRecord::Base.send(:include, HasArrayField)
