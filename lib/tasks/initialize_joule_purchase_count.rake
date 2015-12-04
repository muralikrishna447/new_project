task :initialize_joule_purchase_count => [:environment] do
  puts Analytics.inspect

  # Safe to run more than once because it resets the count
  counts = Hash.new(0)
  fjpa = {}

  StripeOrder.all.each do |order|
    if order.submitted && order.data["circulator_sale"] && ! order.data["gift"]
      counts[order.user_id] += 1
      if fjpa[order.user_id].blank?
        fjpa[order.user_id] = order.created_at
      end
    end
  end

  counts.each do |user_id, count|
    user = User.find(user_id)
    user.update_attribute(:first_joule_purchased_at, fjpa[user_id])
    user.update_attribute(:joule_purchase_count, count)
    Analytics.identify(user_id: user_id, traits: {joule_purchase_count: count})
    Analytics.flush()
    Resque.enqueue(UserSync, user_id)

    puts "User #{user.id} - #{user.email}, count: #{count}, first purchase: #{fjpa[user_id]}"
  end

  puts "Total non-gift Joules purchased #{counts.values.inject { |a, b| a + b }}"
end
