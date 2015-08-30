module AuthorHelper
  def link_to_author(user_attributable, reveal_anon=false)
    display_name = user_attributable.user.try(:name)
    display_name = nil if user_attributable.anonymous and not reveal_anon
    if display_name
      # Guaranteed to have an attached user object
      link_to display_name, profile_path(user_attributable.user)
    else
      "Anonymous User"
    end
  end

  def avatar_url(user_attributable, thumb_class, size)
    if user_attributable.author
      image_tag user_attributable.user.avatar.url(thumb_class), size: size
    else
      image_tag "avatar-missing.svg", size: size
    end
  end
end
