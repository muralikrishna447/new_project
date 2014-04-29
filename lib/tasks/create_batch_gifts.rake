task :create_batch_gifts, [:course_slug, :num] => [:environment]  do |t, args|
  puts args.num
  assembly = Assembly.find(args.course_slug)
  args.num.to_i.times do
    gc = GiftCertificate.create!(
            purchaser_id: 0,
            assembly_id: assembly.id,
            price: 0,
            sales_tax: 0,
            recipient_email: "",
            recipient_name: "Gilt Recipient",
            recipient_message: ""
          )
    puts gc.token
  end
end