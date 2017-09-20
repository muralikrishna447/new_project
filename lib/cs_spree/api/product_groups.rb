module CsSpree::Api::ProductGroups

  DEFAULT_US_JOULE_PRODUCT_GROUP = {
    name: 'Joule',
    description: 'The world’s smallest, smartest, and sexiest sous vide tool, perfect for sous vide novices and veterans alike. iOS or Android required.',
    currency: 'USD',
    products: [
      {
        name: 'Joule: Sous Vide By ChefSteps',
        label: 'Stainless Steel',
        sku: 'cs10001',
        slug: 'joule-sous-vide-by-chefsteps',
        price: 199.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      },
      {
        name: 'Joule White: Sous Vide By ChefSteps',
        label: 'White Polycarbonate',
        sku: 'cs20001',
        slug: 'joule-sous-vide-by-chefsteps-white',
        price: 179.00,
        compare_to_price: 199.00,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }

  DEFAULT_CA_JOULE_PRODUCT_GROUP = {
    name: 'Joule',
    description: 'The world’s smallest, smartest, and sexiest sous vide tool, perfect for sous vide novices and veterans alike. iOS or Android required.',
    warning: 'This product may be incompatible with some Bell Canada WiFi Routers',
    additional_description: 'The iOS and Android Applications are only available in English',
    currency: 'CAD',
    products: [
      {
        label: 'Stainless Steel',
        sku: 'CS20004',
        price: 209.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }


  DEFAULT_US_BIG_CLAMP_PRODUCT_GROUP = {
    name: 'Joule Big Clamp',
    description: 'Works with: Coolers, Cambros, Insulated containers, Any big thing you want to cook in',
    currency: 'USD',
    products: [
      {
        label: 'Joule Big Clamp',
        sku: 'cs30001',
        price: 24.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }

  DEFAULT_CA_BIG_CLAMP_PRODUCT_GROUP = {
    name: 'Joule Big Clamp',
    description: 'Works with: Coolers, Cambros, Insulated containers, Any big thing you want to cook in',
    currency: 'CAD',
    products: [
      {
        label: 'Joule Big Clamp',
        sku: 'cs30001',
        price: 24.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }

  DEFAULT_US_PREMIUM_PRODUCT_GROUP = {
    name: 'Joule Big Clamp',
    description: 'Works with: Coolers, Cambros, Insulated containers, Any big thing you want to cook in',
    currency: 'USD',
    products: [
      {
        label: 'ChefSteps Premium',
        sku: 'cs10002',
        price: 30.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }

  DEFAULT_CA_PREMIUM_PRODUCT_GROUP = {
    name: 'Joule Big Clamp',
    description: 'Works with: Coolers, Cambros, Insulated containers, Any big thing you want to cook in',
    currency: 'CAD',
    products: [
      {
        label: 'ChefSteps Premium',
        sku: 'cs10002',
        price: 30.00,
        compare_to_price: nil,
        orderable: true,
        low_stock: false,
        status: 'orderable', #backorderable, preorderable  ...?
      }
    ]
  }

  DEFAULT_PRODUCT_GROUPS_BY_COUNTRY = {
    'US' => {
      joule: DEFAULT_US_JOULE_PRODUCT_GROUP,
      big_clamp: DEFAULT_US_BIG_CLAMP_PRODUCT_GROUP,
      premium: DEFAULT_US_PREMIUM_PRODUCT_GROUP,
    },
    'CA' => {
      joule: DEFAULT_CA_JOULE_PRODUCT_GROUP,
      big_clamp: DEFAULT_CA_BIG_CLAMP_PRODUCT_GROUP,
      premium: DEFAULT_CA_PREMIUM_PRODUCT_GROUP,
    }
  }

  def self.product_groups_cache_key(up_iso2)
    "cs_spree_api_product_groups_#{up_iso2}"
  end

  def self.for_country(iso2_country_code)
    up_iso2 = iso2_country_code.upcase
    url_path = "/api/v1/countries/#{up_iso2}/cs_product_groups"
    begin
      CacheExtensions::fetch_with_rescue(product_groups_cache_key(up_iso2), 1.hour, 1.minute) do
        CsSpree.get_api(url_path)
      end
    rescue StandardError => e
      Rails.logger.error "Error in  CsSpree.get_api('#{url_path}') #{e}"
      DEFAULT_PRODUCT_GROUPS_BY_COUNTRY.fetch(up_iso2) do
        Rails.logger.error "No default Product Groups configured for #{up_iso2}"
      end
    end
  end
end