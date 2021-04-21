ActiveAdmin.register EmbedPdf do
  actions :all, except: :destroy

  config.batch_actions = false

  permit_params :title, :image_id, :image_alt, :image_longdesc, :pdf_id

  menu parent: 'More'

  filter :title
  filter :slug
  filter :image_alt
  filter :created_at
  filter :updated_at

  controller do
    def create
      super do |_format|
        flash[:error] = resource.errors.full_messages.join(', ') unless resource.valid?
      end
    end
  end

  index do
    id_column
    column :title
    column :slug do |embed_pdf|
      render 'pdf_slug', embed_pdf: embed_pdf
    end
    column :image_alt
    actions
  end

  show do
    attributes_table do
      row :slug do |embed_pdf|
        render 'pdf_slug', embed_pdf: embed_pdf
      end
      row :title
      row :image do |embed_pdf|
        image_tag embed_pdf.image_url
      end
      row :image_alt
      row :image_longdesc
      row :pdf do |embed_pdf|
        link_to '<button>Download</button>'.html_safe, embed_pdf.pdf_id, target: '_blank'
      end
    end
  end

  form partial: 'form'
end
