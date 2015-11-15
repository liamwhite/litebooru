module Notifyable
  extend ActiveSupport::Concern

  included do
    has_array_field :watchers, User
  end

  def notify(user, action, users_to_exclude=[])
    return if watcher_ids.count == 0

    # Find the last notification this was attached to (if any) and clean up.
    Notification.where(actor: self, action: action).each do |n|
      PostgresSet.pull User.where.contains(unread_notification_ids: [n.id]), :unread_notification_ids, n.id
      n.destroy
    end

    # Generate a new notification
    n = Notification.create!(user: user, actor: self, action: action)
    PostgresSet.add_to_set User.where(id: watcher_ids).where.not(id: users_to_exclude), :unread_notification_ids, n.id
    return n
  end

  # Watch activity on this actor
  def subscribe!(user)
    self.update_columns(watcher_ids: self.watcher_ids+[user.id]) if user && !subscribed?(user)
  end

  # Unwatch activity on this actor
  def unsubscribe!(user)
    self.update_columns(watcher_ids: self.watcher_ids-[user.id]) if user && !subscribed?(user)
  end

  def subscribed?(user)
    watcher_ids.include?(user.id) if user
  end

  # Mark notifications on this actor as read for this user
  def mark_all_read(user)
    Notification.where(actor: self).only(:id).each do |n|
      user.update_columns(unread_notification_ids: user.unread_notification_ids-[n.id])

      # Trim notifications with no more users
      if User.where.contains(unread_notification_ids: [n.id]).count == 0
        n.destroy
      end
    end
  end
end
