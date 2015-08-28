# Code by @k-anon

class SearchParser
  attr_reader :search_str, :parsed, :requires_query
  
  @@token_list = [
    [:lparen, /\A\s*\(\s*/],
    [:rparen, /\A\s*\)\s*/],
    [:and, /\A\s*(?:\&\&|AND)\s+/],
    [:and, /\A\s*,\s*/],
    [:or, /\A\s*(?:\|\||OR)\s+/],
    [:not, /\A\s*NOT(?:\s+|(?>\())/],
    [:not, /\A\s*[\!\-]\s*/],
    [:space, /\A\s+/],
    [:word, /\A(?:[^\s,\(\)]|\\[\s,\(\)])+/],
  ]
  
  def initialize(search_str, default_field, allowed_fields=[])
    @search_str = search_str.strip
    # Default search field.
    @default_field = default_field
    @allowed_fields = allowed_fields
    @parsed = parse
  end
  
  def lex
    # Current operator queue
    ops = []
    # Search term storage between match iterations.
    search_term = nil
    # Count any left parentheses within the search term.
    lparen_in_term = 0
    # Term negation
    negate = false
    # Group negation
    group_negate = []
    # Term stack shifted from queue
    token_stack = []
    
    # Shunting-yard algorithm
    while not @search_str.empty?
      @@token_list.each do |token|
        symbol, regexp = token
        match = regexp.match @search_str
        if match
          match = match.to_s
          
          # Add the current search term to the stack once we reach another operator.
          if ([:and, :or].include? symbol) or (symbol == :rparen and lparen_in_term == 0)
            if search_term
              # Push to stack
              token_stack.push search_term
              # Reset options
              lparen_in_term = 0
              search_term = nil
              if negate
                token_stack.push :not
                negate = false
              end
            end
          end
          
          # Otherwise... do something with the token we matched
          case symbol
          when :and
            while ops[0] == :and
              token_stack.push(ops.shift)
            end
            ops.unshift :and
          when :or
            while [:and, :or].include?(ops[0])
              token_stack.push(ops.shift)
            end
            ops.unshift :or
          when :not
            if search_term
              search_term.append(match)
            else
              negate = !negate
            end
          when :lparen
            # If we are inside a search term, consider this as part of the query
            # expression, rather than as a grouping.
            if search_term
              search_term.append(match)
              lparen_in_term += 1
            else
              ops.unshift(:lparen)
              group_negate.push(negate)
            end
          when :rparen
            # Same as above.
            if lparen_in_term != 0
              search_term.append(match)
              lparen_in_term -= 1
            else
              # Shfit operands until a right parenthesis is encountered
              balanced = false
              while not ops.empty?
                op = ops.shift
                if op == :lparen
                  balanced = true
                  break
                end
                token_stack.push(op)
              end
              if not balanced
                raise SearchParsingError, 'Imbalanced parentheses.'
              end
              if group_negate.pop
                token_stack.push(:not)
              end
            end
          when :word
            # Unquoted literal
            if search_term
              search_term.append(match)
            else
              search_term = new_search_term(match)
            end
          else
            # Append extra spaces in terms
            search_term.append(match) if search_term
          end
          
          # Truncate and loop
          @search_str = @search_str.slice(match.size, @search_str.size - match.size)
          break
        end
      end
    end
    
    # Append any last tokens to the stack
    token_stack.push(search_term) if search_term
    token_stack.push(:not) if negate
    
    if ops.any?{|x| [:rparen, :lparen].include?(x)}
      raise SearchParsingError, 'Imbalanced parentheses.'
    end
    token_stack.concat(ops)
    
    return token_stack
  end
  
  def new_search_term(term_str)
    SearchTerm.new(term_str.lstrip, @default_field, @allowed_fields)
  end
  
  def operator_to_bool(operator)
    if operator == :and
      :must
    else
      :should
    end
  end
  
  def tokens
    @tokens ||= lex
  end
  
  def parse
    # Stack for search terms and combinations of search terms
    operand_stack = []
    tokens.each_with_index do |token, idx|
      if token != :not
        negate = (tokens[idx + 1] == :not)
        if token.is_a? SearchTerm
          parsed = token.parse
          @requires_query = true if token.wildcarded
          operand_stack.push [:term, negate, parsed]
        else
          op_2 = operand_stack.pop
          op_1 = operand_stack.pop
          
          if op_1.nil? or op_2.nil?
            raise SearchParsingError, 'Missing operand.'
          end
          operand_stack.push flatten_operands([op_1, op_2], token, negate)
        end
      end
    end
    
    if operand_stack.size > 1
      raise SearchParsingError, 'Missing operator.'
    end
    
    op = operand_stack.pop
    
    if not op
      return {}
    else
      negate = op[1]
      expr = op[2]
      if negate
        return {bool: {must_not: [expr]}}
      end
      return expr
    end
  end
  
  def flatten_operands(ops, operator, negate)
    bool = self.operator_to_bool(operator)
    query = {}
    # Build the array of operands based on the unifying operator
    bool_stack = []
    ops.each do |op_type, negate_term, op|
      if op_type == :term and negate_term
        op = {bool: {must_not: [op]}}
      end
      bool_exp = op[:bool]
      if ((not bool_exp.nil?) and bool_exp.keys.size == 1 and bool_exp.has_key?(bool))
        bool_stack.concat(bool_exp[bool])
      elsif bool_exp.nil? or (not bool_exp.keys.empty?)
        bool_stack.push(op)
      end
    end
    if not bool_stack.empty?
      query[bool] = bool_stack
    end
    
    if negate
      if query.keys.size == 1 and query.has_key? :must_not
        return [:subexp, false, {bool: {must: query[:must_not]}}]
      else
        # Return point when explicit negation at the AST root is needed
        return [:subexp, false, {bool: {must_not: [{bool: query}]}}]
      end
    end
    return [:subexp, false, {bool: query}]
  end
end

class SearchTerm
  attr_accessor :term, :allowed_fields
  attr_reader :wildcarded

  def initialize(term, default_field, allowed_fields=[])
    @term = term
    @default_field = default_field
    @allowed_fields = allowed_fields
  end
  
  def append(str)
    @term.concat(str.downcase)
  end
  
  def prepend(str)
    @term.prepend(str.downcase)
  end
  
  def normalize_val(val, range=nil)
    if %w[lt gt gte lte].include?(range)
      return {range.to_sym => val}
    else
      return val
    end
  end
  
  # Checks any terms with colons for whether a field is specified, and
  # returns [field, value]
  def escape_colons
    args = nil
    
    @term.match(/\A(.*?[^\\]):(.*)\z/) do |m|
      field, val = m[1, 2]
      field.downcase!
      
      # Range query
      if field =~ /(.*)\.([gl]te?|eq)\z/
        range_field = $1.to_sym
        return [range_field, normalize_val(val, $2)]
      end

      field = field.to_sym
      if not @allowed_fields.include?(field)
        return [@default_field, normalize_val("#{field}:#{val}")]
      end

      return [field, normalize_val(val)]
    end
  end
  
  def parse
    wildcardable = !/\A"([^"]|\\")+"\z/.match(term)
    if not wildcardable
      @term = @term.slice(1, @term.size - 2)
    end
    
    field = nil
    if @term.include?(':')
      field, value = escape_colons
    end
    
    # No colon, or escape_colons encountered an unscaped colon
    if not field
      field, value = [@default_field, normalize_val(@term)]
    end
    
    # Range query
    if value.is_a? Hash
      return {range: {field => value}}
    elsif wildcardable and (value =~ /(?:^|[^\\])[\*\?]/)
      # '*' and '?' are wildcard characters in the right context
      value.gsub!(/\\([\A\*\?])/, '\1')
      @wildcarded = true
      if value == '*'
        # All-matching wildcard is just a match_all on the collection
        return {match_all: {}}
      end
      return {wildcard: {field => value}}
    else
      normalize_term! value, (not wildcardable)
      return {term: {field => value} }
    end
  end
  
  def normalize_term!(match, quoted)
    if quoted
      match.gsub!('\"', '"')
    else
      match.gsub!(/\\(.)/, '\1')
    end
  end

  alias to_s term
end

class SearchParsingError < StandardError
end
