ActiveAdmin.register PrivateToken do
  config.filters = false

  menu parent: 'More'

  form do |f|
    f.inputs "Token" do
      f.input :token, input_html: { value: PrivateToken.new_token_string}
    end

    f.buttons
  end
end

