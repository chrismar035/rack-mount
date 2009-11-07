begin
  require 'rack'
rescue LoadError
  warn "Loading rubygems"
  require 'rubygems'
end

require 'test/unit'
require 'rack/mount'
require 'fixtures'

module ControllerConstants
  def const_missing(name)
    if name.to_s =~ /Controller$/
      const_set(name, EchoApp)
    else
      super
    end
  end
end

module Account
  extend ControllerConstants
end

Object.extend(ControllerConstants)

def supports_named_captures?
  Rack::Mount::RegexpWithNamedGroups.supports_named_captures?
end

class Test::Unit::TestCase
  private
    def set_included_modules
      class << @app; included_modules; end
    end

    def env
      @env
    end

    def response
      @response
    end

    def routing_args_key
      'rack.routing_args'
    end

    def routing_args
      @env[routing_args_key]
    end

    def assert_recognizes(params, path)
      req = Rack::Request.new(Rack::MockRequest.env_for(path))
      assert_equal(params, @app.recognize(req))
    end

    def get(path, options = {})
      process(path, options.merge(:method => 'GET'))
    end

    def post(path, options = {})
      process(path, options.merge(:method => 'POST'))
    end

    def put(path, options = {})
      process(path, options.merge(:method => 'PUT'))
    end

    def delete(path, options = {})
      process(path, options.merge(:method => 'DELETE'))
    end

    def process(path, options = {})
      @path = path

      require 'rack/mock'
      env = Rack::MockRequest.env_for(path, options)
      @response = @app.call(env)

      if @response && @response[0] == 200
        @env = YAML.load(@response[2][0])
      else
        @env = nil
      end
    end

    def assert_success
      assert(@response)
      assert_equal(200, @response[0], "No route matches #{@path.inspect}")
    end

    def assert_not_found
      assert(@response)
      assert_equal(404, @response[0])
    end
end
