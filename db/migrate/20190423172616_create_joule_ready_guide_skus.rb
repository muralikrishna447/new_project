class CreateJouleReadyGuideSkus < ActiveRecord::Migration[5.2]
  def change
    create_table :joule_ready_guide_skus, id: false do |t|
      t.string :guide_id
      t.string :sku
      t.string :name
    end
    add_index :joule_ready_guide_skus, [:guide_id], unique: true

    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('4QwQ2C2sww6m8QsIQykoE4', 'cs40001', 'Panang Curry');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('5XLJ3JYMVy0kKsImYa6WIc', 'cs40002', 'Spicy Citrus BBQ');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('2NRxqLD2VqiqcmQw0mEIky', 'cs40003', 'New School Teriyaki');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('4mLAI7RKZiQai2Sc4aWoKU', 'cs40004', 'Roasted Red Pepper Walnut Muhammara');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('3AWO0FhjEkEguwOsc840i0', 'cs40005', 'Lemon Beurre Blanc');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('e98HWT07D2CIYg6wgKIOm ', 'cs40006', 'Teppanyaki Barbecue Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('4CGPTQSipGuqKaMMoWym8k', 'cs40007', 'Creamy Tikka Masala');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('1skShzrlEsIWIwoAcweeGY', 'cs40008', 'Smoked Ancho Chili Adobo');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('4yl601GYFyWiE4GAuoAYY0', 'cs40009', 'Fig & Apricot Mostarda');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('692GzowLgkAAqKeGueaUMi', 'cs40010', 'Sauce au Poivre');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('2Z4qpGN1JKoAEqIyoK60wq', 'cs40011', 'Salsa Chamoy');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('3k2O2DzHCEUgQigImoWSoG', 'cs40012', 'Thai Green Curry');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('2oahR4xs36goS6Mky2g6Oe', 'cs40013', 'Tangy Adobo');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('32nlKWRRv2Aece42YoO8EY', 'cs40014', 'Creamy Carrot');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('nFFL6RFhuKeqUqow4CwM0 ', 'cs40015', 'Spicy Banana Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('6H8SlPOjtYsG2iKykgcMme', 'cs40016', 'Vadouvan Curry');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('5FWrkayi7CuMimckSamEai', 'cs40017', 'Thanks Give Me More Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('3hNRznH6j6yCouueocQyiS', 'cs40018', 'Périgord Black Truffle Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('5tkCyGMl20yi00C2wk8so4', 'cs40019', 'Barbacoa Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('1PO3lxlILWAS6cyIGMoKko', 'cs40020', 'Winter Goulash Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('3kA8s3mqacYumASy6OKiam', 'cs40021', 'Spicy Miso Sesame Sauce');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('5WlHNtRLlC4c6mAq2sAUaQ', 'cs40022', 'Good Gravy');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('nMdwW8RzrTlKL8yJgmAiV ', 'cs40023', 'Red Wine Beef Demi-Glace');"
    execute "INSERT INTO joule_ready_guide_skus (guide_id, sku, name) VALUES ('30tfiUwZ9pkkUk7ID8R2s4', 'cs40024', 'Fire-Roasted Tomato Marinara');"
  end
end
