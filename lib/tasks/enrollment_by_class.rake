task :enrollment_by_class => :environment do
  results = []
  Assembly.all.each do |a|
    e = Enrollment.where(enrollable_id: a.id)
    g = GiftCertificate.where(assembly_id: a.id)
    # Don't include gifts in count because that would double count, but do include price
    count = e.count
    if count > 10
      spent = e.sum(&:price) + e.sum(&:sales_tax) + g.sum(&:price) + g.sum(&:sales_tax)
      results << {title: a.title, count: count, spent: spent}
    end
  end

  total_spent = 0
  results.sort_by { |r| -r[:count] }.each do |r|
    puts "#{r[:title]}: #{r[:count]} enrollments, $#{r[:spent].to_f}"
    total_spent += r[:spent]
  end

  puts "** Total spend: $#{total_spent.to_f}"


end