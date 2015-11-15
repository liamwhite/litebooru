module PostgresSet
  class << self
    def add_to_set(relation, column, value)
      relation.update_all("#{column} = ARRAY(SELECT DISTINCT UNNEST(array_append(#{column}, #{relation.sanitize(value)})) ORDER BY 1)")
    end

    def pull(relation, column, value)
      relation.update_all("#{column} = array_remove(#{column}, #{relation.sanitize(value)})")
    end
  end
end
