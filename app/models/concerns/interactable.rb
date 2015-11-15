module Interactable
  extend ActiveSupport::Concern

  included do
    has_many :user_interactions, validate: false
  end

  #
  # Cast a vote as the given user
  #
  # @param user [User] the user doing the voting
  # @param target_state [:up, :down, false] the vote that should be cast. If false is passed to this argument, remove any existing votes
  #
  # @return [Boolean] true if we did something, false if no action was taken
  def vote!(user, target_state)
    raise ArgumentError, "No user specified" unless user and user.id
    raise ArgumentError, "State not specified" unless [:up, :down, false].include?(target_state)
    # Get the existing vote
    current_state = voted?(user)
    ret = false
    if !current_state or current_state != target_state
      self.with_lock do
        if target_state == :up and current_state == :down
          # Downvote -> Upvote
          if set_interaction(user, 'voted', 'up')
            self.update_columns(score: self.score+2, up_vote_count: self.up_vote_count+1, down_vote_count: self.down_vote_count-1, updated_at: Time.now)
            ret = true
          end
        elsif target_state == :down and current_state == :up
          # Upvote -> Downvote
          if set_interaction(user, 'voted', 'down')
            self.update_columns(score: self.score-2, up_vote_count: self.up_vote_count-1, down_vote_count: self.down_vote_count+1, updated_at: Time.now)
            ret = true
          end
        elsif target_state == :up and current_state == false
          # No Vote -> Upvote
          if set_interaction(user, 'voted', 'up')
            self.update_columns(score: self.score+1, up_vote_count: self.up_vote_count+1, vote_count: self.vote_count+1, updated_at: Time.now)
            ret = true
          end
        elsif target_state == :down and current_state == false
          # No Vote -> Downvote
          if set_interaction(user, 'voted', 'down')
            self.update_columns(score: self.score-1, down_vote_count: self.down_vote_count+1, vote_count: self.vote_count+1, updated_at: Time.now)
            ret = true
          end
        elsif target_state == false and current_state == :up
          # Upvote -> No Vote
          if delete_interaction(user, 'voted')
            self.update_columns(score: self.score-1, up_vote_count: self.up_vote_count-1, vote_count: self.vote_count-1, updated_at: Time.now)
            ret = true
          end
        elsif target_state == false and current_state == :down
          # Downvote -> No Vote
          if delete_interaction(user, 'voted')
            self.update_columns(score: self.score+1, down_vote_count: self.down_vote_count-1, vote_count: self.vote_count-1, updated_at: Time.now)
            ret = true
          end
        end
      end
    end
    return ret
  end

  #
  # Retrieve an existing vote
  #
  # @param user [User] the user who did the voting
  #
  # @return [:up, :down, false] the existing vote direction or false if there is no vote
  def voted?(user)
    raise ArgumentError, "No user specified" unless user and user.id
    interaction = get_interaction(user, 'voted')
    if interaction and interaction.value == 'up'
      return :up
    elsif interaction and interaction.value == 'down'
      return :down
    else
      return false
    end
  end

  #
  # Favourite as the given user
  #
  # @param  user [User] the user doing the faving
  # @param  target_state [true, false] should this be faved or not
  #
  # @return [Boolean] true if we did anything, false if we didn't
  def fave!(user, target_state)
    raise ArgumentError, "No user specified" unless user and user.id
    current_state = faved?(user)
    ret = false
    self.with_lock do
      if target_state == true and current_state == false
        # Not Faved -> Faved
        if set_interaction(user, 'faved')
          self.update_columns(favourites: self.favourites + 1)
          ret = true
        end
      elsif target_state == false and current_state == true
        # Faved -> Not Faved
        if delete_interaction(user, 'faved')
          self.update_columns(favourites: self.favourites - 1)
          ret = true
        end
      end
    end
    return ret
  end

  #
  # Retrieve existing favourite state
  #
  # @param  user [User] the user who faved
  #
  # @return [true, false] true if this user faved this, false if not
  def faved?(user)
    raise ArgumentError, "No user specified" unless user and user.id
    interaction = get_interaction(user, 'faved')
    if interaction
      return true
    else
      return false
    end
  end


  #
  # Sets, but does not save, count fields such that they are accurate based on the DB at this point
  #
  def recount
    self.up_vote_count = self.user_interactions.where(interaction_type: 'voted', value: 'up').count
    self.down_vote_count = self.user_interactions.where(interaction_type: 'voted', value: 'down').count
    self.favourites = self.user_interactions.where(interaction_type: 'faved').count
    self.score = (self.up_vote_count - self.down_vote_count)
    self.vote_count = (self.up_vote_count + self.down_vote_count)
  end

  #
  # Used for indexing purposes
  #
  # @return [Array] Array of user IDs
  def upvoted_user_ids
    @upvoted_user_ids ||= self.user_interactions.where(interaction_type: 'voted', value: 'up').pluck(:user_id)
  end

  #
  # Used for display to admins
  #
  # @return [Array] Array of user IDs
  def downvoted_user_ids
    @downvoted_user_ids ||= self.user_interactions.where(interaction_type: 'voted', value: 'down').pluck(:user_id)
  end

  #
  # Used for indexing purposes
  #
  # @return [Array] Array of user IDs
  def faved_user_ids
    @faved_user_ids ||= self.user_interactions.where(interaction_type: 'faved').pluck(:user_id)
  end

  #
  # Used for elasticsearch/indexing
  #
  # @return [Array] Array of user names
  def faved_user_names
    @faved_user_names ||= self.user_interactions.where(interaction_type: 'faved').includes(:user).map{|t| t.user.name}
  end

  #
  # Migrate the interactions on this model to another.
  #
  # @param  target_interactable [Interactable] The interactable to migrate to
  def migrate_interactions!(target_interactable)
    @faved_user_ids = nil
    @faved_user_names = nil
    @upvoted_user_ids = nil
    @downvoted_user_ids = nil
    @interactions = nil
    self.user_interactions.each do |ui|
      ui.image = target_interactable
      if not ui.save
        # Validation error due to user collision.
        ui.delete
      end
    end
    # A nicer update is possible, but an explicit recount prevents race
    # conditions.
    target_interactable.recount
    target_interactable.save
  end

  protected

  #
  # Find an existing interaction of the specified type for the given user
  #
  # @param  user [User] the user who did the interacting
  # @param  type [String] the UserInteraction type
  #
  # @return [UserInteraction, nil] the interaction or nil if nothing exists
  def get_interaction(user, type)
    self.fetch_interactions(user).detect{|ui|ui.interaction_type == type}
  end


  #
  # Find all interactions for the given user on this interactable.
  # @param  user [User] the user who did the interacting
  #
  # @return [Array] MEMOIZED array of user interactions, memoization wiped on set_interaction call
  def fetch_interactions(user)
    @interactions = {} if !@interactions
    return (@interactions[user.id] ||= self.user_interactions.where(user_id: user.id).all.to_a)
  end

  def reset_interactions(user)
    @interactions = {} if !@interactions
    @interactions[user.id] = nil
  end


  #
  # Create or update an interaction of the specified type for the given user
  #
  # @param  user [User] the user doing the thing
  # @param  type [String] the type of thing being done
  # @param  value [String, nil] the value related to the thing being done - optional
  #
  # @return [Boolean] True if a change was made, false if we made no actual alteration
  def set_interaction(user, type, value=nil)
    # TODO: Could be optimized with an upsert but must maintain return condition behaviour
    existing_interaction = get_interaction(user, type)
    if existing_interaction
      if value != existing_interaction.value
        reset_interactions(user)
        @upvoted_user_ids = nil
        @downvoted_user_ids = nil
        existing_interaction.value = value
        existing_interaction.save!
        return true
      else
        return false
      end
    else
      @faved_user_ids = nil
      @faved_user_names = nil
      reset_interactions(user)
      self.user_interactions.create!(user_id: user.id, interaction_type: type, value: value)
    end
  end

  #
  # Delete an interaction of the specified type for the given user
  #
  # @param  user [User] the user who did the thing
  # @param  type [String] the type of thing that was done
  #
  # @return [Boolean] True if a change was made, false if we made no actual alteration
  def delete_interaction(user, type)
    interaction = get_interaction(user, type)
    if interaction
      @faved_user_ids = nil
      @faved_user_names = nil
      @upvoted_user_ids = nil
      @downvoted_user_ids = nil
      reset_interactions(user)
      interaction.destroy
      return true
    else
      return false
    end
  end
end
