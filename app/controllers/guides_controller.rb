class GuidesController < ApplicationController
    # http://localhost:3000/guides/35eu303TbWcSCcWIqEW0KA
    def show
        @guide_activity = GuideActivity.where(guide_id: params[:id]).first
        if @guide_activity.present?
            logger.info "[GuideController] Matched GuideID #{params[:id]} matched activity #{@guide_activity.activity_id}"
            if @guide_activity.activity_id.present?
                if @guide_activity.activity.published?
                    logger.info "[GuideController] Matched GuideID #{params[:id]} matched activity #{@guide_activity.activity.title}"
                    # This is the norm, where a guide exists and it has an
                    return redirect_to activity_path(@guide_activity.activity)
                else
                    return redirect_to "/joule/app"
                end
            else
                logger.info "[GuideController] Redirecting to the Joule Ready Landing page"
                # This is for Joule Ready where an guide exists but there isn't an activity associated with it
                # Like Joule Ready
                return redirect_to "/joule_ready_landing"
            end
        else
            logger.info "[GuideController] Redirecting to the generic app landing page."
            # This is when a guide doesn't exist at all
            # Show them a page telling them to enjoy the wonder of the app
            return redirect_to "/joule/app"
        end
    end

    # Putting these here for now, though we might want to change it later
    def apple
        apple_creds = {"applinks" => { "apps" => [], "details" => [{ "appID" => "6PR62W26GL.com.chefsteps.circulator", "paths" => [ "/guides/*", "/jr/*"]}] } }
        render(json: apple_creds.to_json)
    end

    def google
        google_creds = [{"relation" => ["delegate_permission/common.handle_all_urls"],"target" => { "namespace" => "android_app", "package_name" => "com.chefsteps.circulator", "sha256_cert_fingerprints" => ["65:CB:4B:79:CE:95:E9:B8:30:5E:56:55:71:23:35:60:EF:E8:06:BE:37:AC:A1:78:FE:55:00:71:28:5E:B9:9D"] } }]
        render(json: google_creds.to_json)
    end
end
