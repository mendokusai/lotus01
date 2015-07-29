require 'lotus'

module ::OneFile
  class Application < Lotus::Application
    configure do
      routes do
        get '/', to: 'home#index'
      end
    end
    load!
  end

  module Controllers
    module Home
      include OneFile::Controller

      class Index
        include OneFile::Action
        expose :time

        def call(params)
          @time = Time.now
        end
      end
    end
  end

  module Views
    module Home
      class Index
        include OneFile::View

        def render
          "Current time: #{time}. checkout: http://kimh.github.io/blog/en/lotus/creating-web-application-with-ruby-lotus/"
        end
      end
    end
  end
end

run ::OneFile::Application.new