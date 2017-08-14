namespace :cs_spree do
  task :ensure_sharejoule_promo, [:code] => [:environment] do |t, args|
    puts args.code
    p CsSpree::Api::Promotions.ensure_share_joule(args.code)
  end
end
