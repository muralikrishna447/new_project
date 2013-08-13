class Stream
  def self.recieved(user)
    user.events.timeline.where(action: 'received_create').order('created_at asc').uniq!{|e| e.group_name}
  end

  def self.created(user)
    user.events.includes(:trackable).timeline.where('action != ?', 'received_create').order('created_at asc').uniq!{|e| e.group_name}
  end

  def self.followings(user)
    stream_events = Event.includes(:trackable).timeline.where(user_id: user.following_ids).where('action != ?', 'received_create').order('created_at asc')
    # TODO find out why uniq and uniq! sometimes works
    # stream_events.uniq{|e| e.group_name}
  end

  def self.all_events
    Event.timeline.where('action != ?', 'received_create').order('created_at desc')
  end
end