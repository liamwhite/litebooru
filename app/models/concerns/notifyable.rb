module Notifyable
  extend ActiveSupport::Concern

  included do
    has_array_field :watchers, User
  end

  def notify(user, action, users_to_exclude=[])
    return if watcher_ids.count == 0

    # Find the last notification this was attached to (if any) and clean up.
    Notification.where(actor: self, action: action).each do |n|
      User.in(unread_notification_ids: [n.id]).pull(unread_notification_ids: n.id)
      n.destroy
    end

    # Generate a new notification
    n = Notification.create!(user: user, actor: self, action: action)
    User.in(id: watcher_ids).not_in(id: users_to_exclude).add_to_set(unread_notification_ids: n.id)
    return n
  end

  # Watch activity on this actor
  def subscribe!(user)
    self.add_to_set(watcher_ids: user.id) if user and not subscribed?(user)
  end

  # Unwatch activity on this actor
  def unsubscribe!(user)
    self.pull(watcher_ids: user.id) if user and subscribed?(user)
  end

  def subscribed?(user)
    watcher_ids.include?(user.id) if user
  end

  # Mark notifications on this actor as read for this user
  def mark_all_read(user)
    Notification.where(actor: self).only(:id).each do |n|
      user.pull(unread_notification_ids: n.id)

      # Trim notifications with no more users
      if User.in(unread_notification_ids: [n.id]).count == 0
        n.destroy
      end
    end
  end
end
