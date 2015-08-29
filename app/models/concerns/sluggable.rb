# Provides slug support for a model
module Sluggable
  extend ActiveSupport::Concern

  included do
    field :slug, type: String
    index slug: 1
    validates :slug, uniqueness: true, presence: true

    before_validation do
      set_slug if not self.persisted?
    end
  end

  class_methods do
    def generate_slug(name)
      new_name = name.clone
      # dash
      new_name.gsub!(/\A\-/,'dash-')
      new_name.gsub!(/\-\z/,'-dash')
      new_name.gsub!('-', '-dash-')
      # slashes
      new_name.gsub!(/\A\//,'fwslash-')
      new_name.gsub!(/\/\z/,'-fwslash')
      new_name.gsub!('/', '-fwslash-')
      new_name.gsub!(/\A\\/,'bwslash-')
      new_name.gsub!(/\\\z/,'-bwslash')
      new_name.gsub!('\\', '-bwslash-')
      # colon
      new_name.gsub!(/\A\:/,'colon-')
      new_name.gsub!(/\:\z/,'-colon')
      new_name.gsub!(':', '-colon-')
      # dot
      new_name.gsub!(/\A\./,'dot-')
      new_name.gsub!(/\.\z/,'-dot')
      new_name.gsub!('.', '-dot-')
      # plus
      new_name.gsub!(/\A\+/,'plus-')
      new_name.gsub!(/\+\z/,'-plus')
      new_name.gsub!('+', '-plus-')
      CGI.escape(new_name).gsub('%20','+')
    end

    def set_slugged_field(field_name)
      @@slugged_field = field_name.to_sym
    end
  end

  def set_slug
    if self.slug and not self.changed.include? @@slugged_field.to_s
      return self.slug
    end
    self.slug = self.class.generate_slug(self.send(@@slugged_field))
  end
end
