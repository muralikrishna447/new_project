module ShipwireImport
  SHOPIFY_EXPORT_SCHEMA = [
    'id',
    'name',
    'processed_at',
    'shipping_name',
    'shipping_address_1',
    'shipping_address_2',
    'shipping_city',
    'shipping_province',
    'shipping_zip',
    'shipping_country',
    'email',
    'shipping_phone',
    'sku',
    'quantity',
    'processed_at_index'
  ]

  SHOPIFY_EXPORT_SCHEMA_WITH_PRIORITY = [
    'id',
    'name',
    'processed_at',
    'shipping_name',
    'shipping_address_1',
    'shipping_address_2',
    'shipping_city',
    'shipping_province',
    'shipping_zip',
    'shipping_country',
    'email',
    'shipping_phone',
    'sku',
    'quantity',
    'processed_at_index',
    'priority_index'
  ]

  SHOPIFY_EXPORT_SCHEMA_PROCESSED_AT_COLUMN = 2

  SHOPIFY_EXPORT_SCHEMA_PROCESSED_AT_INDEX_COMLUMN = 14
end
