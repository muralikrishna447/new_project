class AdminController < ApplicationController

  def become
    return unless current_user && current_user.admin?
    sign_in(:user, User.find(params[:id]))
    redirect_to root_url # or user_root_url
  end

  def slack_display
    if params[:token] != ENV["SLACK_SLASH_USER_TOKEN"]
      render_unauthorized
      return
    end

    user = nil
    if params[:text].to_i != 0
      user = User.where(id: params[:text]).first
    else
      user = User.where('email iLIKE ?', params[:text]).first
    end

    if ! user
      render 'slack_display', json: {
        response_type: "in_channel",
        text: "I couldn't find that user :poop:!"
      }
    else
      render 'slack_display', json: {
        response_type: "in_channel",
        text: render_to_string(formats: [:text], template: 'admin/slack_display', layout: false, locals: {user: user, circulator_users: user.circulator_users.includes([:circulator]), tz: "Pacific Time (US & Canada)"})
      }
    end
  end
end