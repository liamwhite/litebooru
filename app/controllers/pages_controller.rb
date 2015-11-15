class PagesController < ApplicationController
  def activity
    @recent_comments = Comment.order(created_at: :desc).limit(5)
  end

  def notifications
  end
end
