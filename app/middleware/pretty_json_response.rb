class PrettyJsonResponse
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if headers["Content-Type"] =~ /^application\/json/ 
      begin
        obj = JSON.parse(response.body)
        pretty_str = JSON.pretty_unparse(obj)
        response = [pretty_str]
        headers["Content-Length"] = Rack::Utils.bytesize(pretty_str).to_s
      rescue
        # If we can't parse, don't worry about i
      end
    end
    [status, headers, response]
  end
end