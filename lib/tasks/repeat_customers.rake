task :repeat_customers, [:start_date_string, :end_date_string] => :environment  do |t, args|
  start_date = Date.parse(args.start_date_string)
  end_date = Date.parse(args.end_date_string)

  enrollments = Enrollment.where("price > 0").where("created_at >= ?", start_date).where("created_at <= ?", end_date)
  gifts = GiftCertificate.where("price > 0").where("created_at >= ?", start_date).where("created_at <= ?", end_date)

  users = (enrollments.includes(:user).map(&:user_id) + gifts.includes(:user).map(&:purchaser_id)).uniq()

  total_sales = enrollments.sum(&:price) + enrollments.sum(&:sales_tax) + gifts.sum(&:price) + gifts.sum(&:sales_tax)
  total_sales_count = enrollments.count + gifts.count

  repeat_customers_count = 0
  users.each do |uid| 
    user = User.find(uid)
    user_purchases = user.enrollments.where("price > 0") + GiftCertificate.where(purchaser_id: uid).where("price > 0")
    repeat_customers_count += 1 if user_purchases.count > 1
  end



  puts "--- During the period from #{start_date} to #{end_date} ---"
  puts ""
  puts "Total purchases: #{total_sales_count}"
  puts "Unique customers: #{users.count}"
  puts "Total sales: $#{total_sales.round(2)}"
  puts "Average price (incl tax): $#{(total_sales / total_sales_count).round(2)}"
  puts "Average classes sold per customer: #{(1.0 * total_sales_count / users.count).round(2)}"
  puts "Average spend per customer: $#{(total_sales / users.count).round(2)}"
  puts ""
  puts "--- Long term behavior of those users ----"
  puts "Number of those customers that have bought at least two classes ever: #{repeat_customers_count}"
  puts "Percent of repeat customers: #{(100 * repeat_customers_count / users.count)}%"

end