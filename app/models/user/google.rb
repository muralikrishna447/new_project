require 'nokogiri'
require 'google/api_client'
require 'google/api_client/client_secrets'

module User::Google
  extend ActiveSupport::Concern

  def connected_with_google?
    self.google_user_id.present?
  end

  def find_google_contact_friends(google_app_id, google_secret)
    return nil unless connected_with_google?
    gather_contacts(google_app_id, google_secret) do |contacts|
      current_users = User.where(email: contacts.map{|c| c[:email]})
      return current_users
    end

  end

  def gather_google_contacts(google_app_id, google_secret)
    return nil unless connected_with_google?
    gather_contacts(google_app_id, google_secret) do |contacts|
      current_users = User.where(email: contacts.map{|c| c[:email]}).pluck(:email)
      contacts = contacts.reject{|c| current_users.include?(c[:email])}
      return contacts.sort{|a,b| a[:name].downcase <=> b[:name].downcase}
    end
  end

  def google_connect(user_options)
    self.update_attributes({google_user_id: user_options[:google_user_id], google_refresh_token: user_options[:google_refresh_token], google_access_token: user_options[:google_access_token]})
  end

  def gather_contacts(google_app_id, google_secret, &block)
    authorization = self.class.create_authorization(google_app_id, google_secret)
    authorization.update_token!(refresh_token: google_refresh_token, access_token: google_access_token)
    begin
      groups_request = authorization.fetch_protected_resource(uri: "https://www.google.com/m8/feeds/groups/default/full/6?v=3.0")
      group = Nokogiri::XML(groups_request.body).css("id").text
      contacts_request = authorization.fetch_protected_resource(uri: "https://www.google.com/m8/feeds/contacts/default/full/?max-results=100000&v=3.0&group=#{group}")
      xml = Nokogiri::XML(contacts_request.body)
      contacts = []
      entries = xml.search("entry")
      entries.each do |entry|
        contact = {email: nil, name: nil}
        contact[:name] = entry.xpath(entry.path + "//gd:fullName").text
        contact[:email] = entry.xpath(entry.path + "//gd:email[@primary='true']/@address").text
        contact[:email] = entry.at_xpath(entry.path + "//gd:email/@address").try(:text) if contact[:email].blank?
        contacts << contact if contact[:email].present?
      end
      block.call(contacts)
    rescue Signet::AuthorizationError
      new_token = authorization.fetch_access_token!
      update_attribute(:google_access_token, new_token["access_token"])
      retry
    end
  end

  module ClassMethods
    def google_connect(user_options)
      User.where("users.email = :email OR users.google_user_id = :google_user_id", user_options).
        first_or_initialize(user_options.merge(password: Devise.friendly_token[0,20]))
    end

    # This is some magic shit, here are some links that helped me
    # https://developers.google.com/+/web/signin/server-side-flow
    # https://github.com/google/google-api-ruby-client
    # https://github.com/google/google-api-ruby-client-samples
    def gather_info_from_google(params, google_app_id, google_secret)
      client = Google::APIClient.new(:application_name => 'Chefsteps', :application_version => 'beta', auto_refresh_token: true)
      info = client.discovered_api('oauth2', 'v2')
      google_params = params[:google]
      authorization = create_authorization(google_app_id, google_secret)
      authorization.code = google_params[:code]
      authorization.fetch_access_token!
      results = client.execute( :api_method => info.userinfo.get, :authorization => authorization )
      email = results.data.email
      name = results.data.name
      google_user_id = results.data.id
      google_refresh_token = authorization.refresh_token
      google_access_token = authorization.access_token
      return {email: email, name: name, google_user_id: google_user_id, google_refresh_token: google_refresh_token, google_access_token: google_access_token}
    end

    def create_authorization(google_app_id, google_secret)
      data = File.open(Rails.root.join("config", "client_secrets.json")) { |file| MultiJson.load(file.read) }
      data["web"].merge!("redirect_uris" => ["postmessage"], "client_secret" => google_secret, "client_id" => google_app_id)
      client_secrets = Google::APIClient::ClientSecrets.new(data)
      authorization = client_secrets.to_authorization
    end
  end
end
