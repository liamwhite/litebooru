module Notifyable
  extend ActiveSupport::Concern

  included do
    has_many :watchers, inverse_of: nil, validate: false, class_name: 'User'
  end

  def notify(user, action, users_to_exclude=[])
    # Find the last notification this was attached to (if any) and clean up.
    Notification.where(actor: self, action: action).each do |n|
      User.in(unread_notification_ids: [n.id]).pull(unread_notification_ids: n.id)
      n.destroy
    end

    # Generate a new notification
    n = Notification.new
    n.user = user
    n.actor = self
    n.action = action
    n.save!
    User.in(id: watcher_ids).not_in(id: users_to_exclude).add_to_set(unread_notification_ids: n.id)
    return n
  end

  # Mark notifications on this actor as read for this user
  def mark_all_read(user)
    Notification.where(actor: self).only(:id).each do |n|
      user.pull(unread_notification_ids: n.id)
    end
  end

  def trim_notifications
    Notification.where(actor: self).only(:id).each do |n|
      # Trim notifications with no more users
      if User.in(unread_notification_ids: [n.id]).count == 0
        n.destroy
      end
    end
  end
end
