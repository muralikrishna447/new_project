ActiveAdmin.register PrivateToken do
  config.filters = false
  permit_params :token

  menu parent: 'More'

  form do |f|
    f.inputs "Token" do
      f.input :token, input_html: { value: PrivateToken.new_token_string}
    end

    f.actions
  end
end

