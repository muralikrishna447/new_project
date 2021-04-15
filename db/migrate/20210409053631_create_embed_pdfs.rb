class CreateEmbedPdfs < ActiveRecord::Migration[5.2]
  def change
    create_table :embed_pdfs do |t|
      t.string :title
      t.text   :image_id
      t.string :image_alt
      t.text   :image_longdesc
      t.string :pdf_id
      t.string :slug

      t.timestamps
    end

    add_index :embed_pdfs, :slug, unique: true
  end
end
