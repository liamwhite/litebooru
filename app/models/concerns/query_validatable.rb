module QueryValidatable
  extend ActiveSupport::Concern

  included do
    validate do
      if defined?(@@query_fields)
        for field_name, target_model in @@query_fields
          begin
            target_model.get_search_parser.call(self.send(field_name))
          rescue => ex
            self.errors.add(field_name, ex.message)
          end
        end
      end
    end
  end

  class_methods do
    def validates_query_string(field_name, target_model=Image)
      if defined?(@@query_fields)
        @@validated_query_fields << [field_name, target_model]
      else
        @@validated_query_fields = [[field_name, target_model]]
      end
    end
  end
end
