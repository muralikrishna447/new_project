class CreateMarketplaceGuides < ActiveRecord::Migration[5.2]
  def change
    create_table :marketplace_guides do |t|
      t.string :guide_id
      t.string :url
      t.string :button_text
      t.string :button_text_line_2

      t.timestamps
    end

    #pulled from MarketplaceController
    marketplace_guides = {
        '3N1qPSrcViOGEYCeaG6io4' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks'
        },
        '6h1aaoAJcAeGuoAgQs28kw' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-kurobuta-pork-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop pork',
        },
        '1EufIMhjAMmc0UoWyEOmIs' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
        },
        'pBOwIfZdDiOeo4egsUg0C' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-kurobuta-pork-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop pork',
        },
        '6U0Sv3hcDm06oCk0W8iO6m' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
        },
        '6ORApkpQQ04IcKse0qIW8k' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf",
            button_text: 'Shop steaks',
        },
        '4Abjel4yI8esSEwcIAoqws' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/wagyu-beef-brisket?utm_source=App&utm_medium=post&utm_campaign=wagyu_beef_brisket_app",
            button_text: 'Shop brisket',
            button_text_line_2: '$84',
        },
        'JIO8hrpTywMCSI40KswcY' => {
            url: "https://#{Rails.configuration.shopify[:store_domain]}/products/72-hour-short-ribs?utm_source=App&utm_medium=post&utm_campaign=short_ribs",
            button_text: 'Shop short ribs',
            button_text_line_2: '$84',
        },
    }

    marketplace_guides.each do |guide_id, guide_params|
      MarketplaceGuide.create(
          guide_id: guide_id,
          url: guide_params[:url],
          button_text: guide_params[:button_text],
          button_text_line_2: guide_params[:button_text_line_2])
    end
  end
end



