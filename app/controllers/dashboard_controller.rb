class DashboardController < ApplicationController
  before_filter :authenticate_active_admin_user!

  def index
    # @user_signups = User.order('created_at ASC').map(&:created_at).group_by(&:end_of_day).map{|k,v| [k.to_date, v.count]}
    @users = User
    @users_count = @users.count
    @users_trend = @users.trend_by_day.last(10)

    # @users_ten_views = User.joins(:events).select('events.user_id').group('events.user_id').having('count(events.id) >=10').count
    # @users_ten_views_count = @users_ten_views.count

    # @users_ten_views_trend = []
    # (0..3).each do |days_ago|
    #   date = Date.today - days_ago
    #   query = User.joins(:events).where('events.created_at < ?', date).select('events.user_id').group('events.user_id').having('count(events.id) >=10').count.sort_by{|k,v| v}.reverse
    #   @users_ten_views_trend << [date, query]
    # end
    # @users_ten_views_trend = User.joins(:events).where('events.created_at > ?', Date.yesterday).select('events.user_id').group('events.user_id').having('count(events.id) >=10').count

    @enrollments_count = Enrollment.count
    @uploads_count = User.joins(:uploads).select('uploads.user_id').group('uploads.user_id').count
    @assemblies = Assembly.pubbed_courses

    @enrollments_trends = []
    @assemblies.each do |assembly|
      trend = assembly.enrollments.trend_by_day.last(10)
      @enrollments_trends << trend
    end

    @new_users_last_week = @users.where("users.created_at > ?", 1.week.ago)
    @new_active_users = @new_users_last_week.joins(:events).group('users.id').having("count(events.user_id) >= 3")
    @new_very_active_users = @new_users_last_week.joins(:events).group('users.id').having("count(events.user_id) >= 10")

  end

  def ftue
    @users = User.where("survey_results IS NOT NULL").reject{|u| u.survey_results.blank?}

    @amateurs = []
    @users.each do |user|
      user.survey_results.each do |result|
        if result['search_scope'] == 'difficulty' && result['answer'] == 'Amateur'
          @amateurs << user
        end
      end
    end

    @homecooks = []
    @users.each do |user|
      user.survey_results.each do |result|
        if result['search_scope'] == 'difficulty' && result['answer'] == 'Home Cook'
          @homecooks << user
        end
      end
    end

    @students = []
    @users.each do |user|
      user.survey_results.each do |result|
        if result['search_scope'] == 'difficulty' && result['answer'] == 'Culinary Student'
          @students << user
        end
      end
    end

    @professionals = []
    @users.each do |user|
      user.survey_results.each do |result|
        if result['search_scope'] == 'difficulty' && result['answer'] == 'Professional'
          @professionals << user
        end
      end
    end
  end

  def comments
  end

end