module HasArrayField
  extend ActiveSupport::Concern

  class_methods do
    def has_array_field(sym, klass=nil)
      klass ||= sym.to_s.singularize.capitalize.constantize
      sym_as_field = "#{sym.to_s.singularize}_ids".to_sym

      # Override pluralized class names
      send :define_method, sym.to_sym do
        _get_array_field(sym_as_field, klass)
      end
      send :define_method, "#{sym}=".to_sym do |*vals|
        _assign_array_field(sym_as_field, klass, *vals)
      end
      true
    end
  end

  def _get_array_field(sym_as_field, klass)
    klass.where(id: self.send(sym_as_field))
  end

  def _assign_array_field(sym_as_field, klass, *vals)
    new_vals = []
    vals.flatten.each do |v|
      if v.is_a? ActiveRecord::Base
        new_vals << v if v.persisted?
      else
        new_vals << klass.find_by(id: v)
      end
    end
    new_vals.compact!
    self.method("#{sym_as_field}=".to_sym).call(new_vals.map(&:id))
    return new_vals
  end
end

# include the extension 
ActiveRecord::Base.send(:include, HasArrayField)
