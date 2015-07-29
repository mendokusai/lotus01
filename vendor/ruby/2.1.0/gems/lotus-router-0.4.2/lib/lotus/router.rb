require 'lotus/routing/http_router'
require 'lotus/routing/namespace'
require 'lotus/routing/resource'
require 'lotus/routing/resources'

module Lotus
  # Rack compatible, lightweight and fast HTTP Router.
  #
  # @since 0.1.0
  #
  # @example It offers an intuitive DSL, that supports most of the HTTP verbs:
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new do
  #     get     '/', to: endpoint # => get and head requests
  #     post    '/', to: endpoint
  #     put     '/', to: endpoint
  #     patch   '/', to: endpoint
  #     delete  '/', to: endpoint
  #     options '/', to: endpoint
  #     trace   '/', to: endpoint
  #   end
  #
  #
  #
  # @example Specify an endpoint with `:to` (Rack compatible object)
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new do
  #     get '/', to: endpoint
  #   end
  #
  #   # :to is mandatory for the default resolver (`Lotus::Routing::EndpointResolver.new`),
  #   # This behavior can be changed by passing a custom resolver to `Lotus::Router#initialize`
  #
  #
  #
  # @example Specify an endpoint with `:to` (controller and action string)
  #   require 'lotus/router'
  #
  #   router = Lotus::Router.new do
  #     get '/', to: 'articles#show' # => Articles::Show
  #   end
  #
  #   # This is a builtin feature for a Lotus::Controller convention.
  #
  #
  #
  # @example Specify a named route with `:as`
  #   require 'lotus/router'
  #
  #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
  #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org') do
  #     get '/', to: endpoint, as: :root
  #   end
  #
  #   router.path(:root) # => '/'
  #   router.url(:root)  # => 'https://lotusrb.org/'
  #
  #   # This isn't mandatory for the default route class (`Lotus::Routing::Route`),
  #   # This behavior can be changed by passing a custom route to `Lotus::Router#initialize`
  #
  # @example Mount an application
  #   require 'lotus/router'
  #
  #   router = Lotus::Router.new do
  #     mount Api::App, at: '/api'
  #   end
  #
  #   # All the requests starting with "/api" will be forwarded to Api::App
  class Router
    # Initialize the router.
    #
    # @param options [Hash] the options to initialize the router
    #
    # @option options [String] :scheme The HTTP scheme (defaults to `"http"`)
    # @option options [String] :host The URL host (defaults to `"localhost"`)
    # @option options [String] :port The URL port (defaults to `"80"`)
    # @option options [Object, #resolve, #find, #action_separator] :resolver
    #   the route resolver (defaults to `Lotus::Routing::EndpointResolver.new`)
    # @option options [Object, #generate] :route the route class
    #   (defaults to `Lotus::Routing::Route`)
    # @option options [String] :action_separator the separator between controller
    #   and action name (eg. 'dashboard#show', where '#' is the :action_separator)
    # @option options [Array<Symbol,String,Object #mime_types, parse>] :parsers
    #   the body parsers for mime types
    #
    # @param blk [Proc] the optional block to define the routes
    #
    # @return [Lotus::Router] self
    #
    # @since 0.1.0
    #
    # @example Basic example
    #   require 'lotus/router'
    #
    #   endpoint = ->(env) { [200, {}, ['Welcome to Lotus::Router!']] }
    #
    #   router = Lotus::Router.new
    #   router.get '/', to: endpoint
    #
    #   # or
    #
    #   router = Lotus::Router.new do
    #     get '/', to: endpoint
    #   end
    #
    # @example Body parsers
    #   require 'json'
    #   require 'lotus/router'
    #
    #   # It parses JSON body and makes the attributes available to the params
    #
    #   endpoint = ->(env) { [200, {},[env['router.params'].inspect]] }
    #
    #   router = Lotus::Router.new(parsers: [:json]) do
    #     patch '/books/:id', to: endpoint
    #   end
    #
    #   # From the shell
    #
    #   curl http://localhost:2300/books/1    \
    #     -H "Content-Type: application/json" \
    #     -H "Accept: application/json"       \
    #     -d '{"published":"true"}'           \
    #     -X PATCH
    #
    #   # It returns
    #
    #   [200, {}, ["{:published=>\"true\",:id=>\"1\"}"]]
    #
    # @example Custom body parser
    #   require 'lotus/router'
    #
    #   class XmlParser
    #     def mime_types
    #       ['application/xml', 'text/xml']
    #     end
    #
    #     # Parse body and return a Hash
    #     def parse(body)
    #       # ...
    #     end
    #   end
    #
    #   # It parses XML body and makes the attributes available to the params
    #
    #   endpoint = ->(env) { [200, {},[env['router.params'].inspect]] }
    #
    #   router = Lotus::Router.new(parsers: [XmlParser.new]) do
    #     patch '/authors/:id', to: endpoint
    #   end
    #
    #   # From the shell
    #
    #   curl http://localhost:2300/authors/1 \
    #     -H "Content-Type: application/xml" \
    #     -H "Accept: application/xml"       \
    #     -d '<name>LG</name>'               \
    #     -X PATCH
    #
    #   # It returns
    #
    #   [200, {}, ["{:name=>\"LG\",:id=>\"1\"}"]]
    def initialize(options = {}, &blk)
      @router = Routing::HttpRouter.new(options)
      define(&blk)
    end

    # Returns self
    #
    # This is a duck-typing trick for compatibility with `Lotus::Application`.
    # It's used by `Lotus::Routing::RoutesInspector` to inspect both apps and
    # routers.
    #
    # @return [self]
    #
    # @since 0.2.0
    # @api private
    def routes
      self
    end

    # To support defining routes in the `define` wrapper.
    #
    # @param blk [Proc] the block to define the routes
    #
    # @return [Lotus::Routing::Route]
    #
    # @since 0.2.0
    #
    # @example In Lotus framework
    #   class Application < Lotus::Application
    #     configure do
    #       routes 'config/routes'
    #     end
    #   end
    #
    #   # In `config/routes`
    #
    #   define do
    #     get # ...
    #   end
    def define(&blk)
      instance_eval(&blk) if block_given?
    end

    # Check if there are defined routes
    #
    # @return [TrueClass,FalseClass] the result of the check
    #
    # @since 0.2.0
    # @api private
    #
    # @example
    #
    #   router = Lotus::Router.new
    #   router.defined? # => false
    #
    #   router = Lotus::Router.new { get '/', to: ->(env) { } }
    #   router.defined? # => true
    def defined?
      @router.routes.any?
    end

    # Defines a route that accepts a GET request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @since 0.1.0
    #
    # @example Fixed matching string
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus', to: ->(env) { [200, {}, ['Hello from Lotus!']] }
    #
    # @example String matching with variables
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/flowers/:id',
    #     to: ->(env) {
    #       [
    #         200,
    #         {},
    #         ["Hello from Flower no. #{ env['router.params'][:id] }!"]
    #       ]
    #     }
    #
    # @example Variables Constraints
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/flowers/:id',
    #     id: /\d+/,
    #     to: ->(env) { [200, {}, [":id must be a number!"]] }
    #
    # @example String matching with globbling
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/*',
    #     to: ->(env) {
    #       [
    #         200,
    #         {},
    #         ["This is catch all: #{ env['router.params'].inspect }!"]
    #       ]
    #     }
    #
    # @example String matching with optional tokens
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus(.:format)',
    #     to: ->(env) {
    #       [200, {}, ["You've requested #{ env['router.params'][:format] }!"]]
    #     }
    #
    # @example Named routes
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/lotus',
    #     to: ->(env) { [200, {}, ['Hello from Lotus!']] },
    #     as: :lotus
    #
    #   router.path(:lotus) # => "/lotus"
    #   router.url(:lotus)  # => "https://lotusrb.org/lotus"
    #
    # @example Duck typed endpoints (Rack compatible objects)
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #
    #   router.get '/lotus',      to: ->(env) { [200, {}, ['Hello from Lotus!']] }
    #   router.get '/middleware', to: Middleware
    #   router.get '/rack-app',   to: RackApp.new
    #   router.get '/method',     to: ActionControllerSubclass.action(:new)
    #
    #   # Everything that responds to #call is invoked as it is
    #
    # @example Duck typed endpoints (strings)
    #   require 'lotus/router'
    #
    #   class RackApp
    #     def call(env)
    #       # ...
    #     end
    #   end
    #
    #   router = Lotus::Router.new
    #   router.get '/lotus', to: 'rack_app' # it will map to RackApp.new
    #
    # @example Duck typed endpoints (string: controller + action)
    #   require 'lotus/router'
    #
    #   module Flowers
    #     class Index
    #       def call(env)
    #         # ...
    #       end
    #     end
    #   end
    #
    #    router = Lotus::Router.new
    #    router.get '/flowers', to: 'flowers#index'
    #
    #    # It will map to Flowers::Index.new, which is the
    #    # Lotus::Controller convention.
    def get(path, options = {}, &blk)
      @router.get(path, options, &blk)
    end

    # Defines a route that accepts a POST request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def post(path, options = {}, &blk)
      @router.post(path, options, &blk)
    end

    # Defines a route that accepts a PUT request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def put(path, options = {}, &blk)
      @router.put(path, options, &blk)
    end

    # Defines a route that accepts a PATCH request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def patch(path, options = {}, &blk)
      @router.patch(path, options, &blk)
    end

    # Defines a route that accepts a DELETE request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def delete(path, options = {}, &blk)
      @router.delete(path, options, &blk)
    end

    # Defines a route that accepts a TRACE request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def trace(path, options = {}, &blk)
      @router.trace(path, options, &blk)
    end

    # Defines a route that accepts a OPTIONS request for the given path.
    #
    # @param path [String] the relative URL to be matched
    #
    # @param options [Hash] the options to customize the route
    # @option options [String,Proc,Class,Object#call] :to the endpoint
    #
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @return [Lotus::Routing::Route] this may vary according to the :route
    #   option passed to the constructor
    #
    # @see Lotus::Router#get
    #
    # @since 0.1.0
    def options(path, options = {}, &blk)
      @router.options(path, options, &blk)
    end

    # Defines an HTTP redirect
    #
    # @param path [String] the path that needs to be redirected
    # @param options [Hash] the options to customize the redirect behavior
    # @option options [Fixnum] the HTTP status to return (defaults to `301`)
    #
    # @return [Lotus::Routing::Route] the generated route.
    #   This may vary according to the `:route` option passed to the initializer
    #
    # @since 0.1.0
    #
    # @see Lotus::Router
    #
    # @example
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     redirect '/legacy',  to: '/new_endpoint'
    #     redirect '/legacy2', to: '/new_endpoint2', code: 302
    #   end
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.redirect '/legacy',  to: '/new_endpoint'
    def redirect(path, options = {}, &endpoint)
      get(path).redirect @router.find(options), options[:code] || 301
    end

    # Defines a Ruby block: all the routes defined within it will be namespaced
    # with the given relative path.
    #
    # Namespaces blocks can be nested multiple times.
    #
    # @param namespace [String] the relative path where the nested routes will
    #   be mounted
    # @param blk [Proc] the block that defines the resources
    #
    # @return [Lotus::Routing::Namespace] the generated namespace.
    #
    # @since 0.1.0
    #
    # @see Lotus::Router
    #
    # @example Basic example
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     namespace 'trees' do
    #       get '/sequoia', to: endpoint # => '/trees/sequoia'
    #     end
    #   end
    #
    # @example Nested namespaces
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     namespace 'animals' do
    #       namespace 'mammals' do
    #         get '/cats', to: endpoint # => '/animals/mammals/cats'
    #       end
    #     end
    #   end
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.namespace 'trees' do
    #     get '/sequoia', to: endpoint # => '/trees/sequoia'
    #   end
    def namespace(namespace, &blk)
      Routing::Namespace.new(self, namespace, &blk)
    end

    # Defines a set of named routes for a single RESTful resource.
    # It has a built-in integration for Lotus::Controller.
    #
    # @param name [String] the name of the resource
    # @param options [Hash] a set of options to customize the routes
    # @option options [Array<Symbol>] :only a subset of the default routes
    #   that we want to generate
    # @option options [Array<Symbol>] :except prevent the given routes to be
    #   generated
    # @param blk [Proc] a block of code to generate additional routes
    #
    # @return [Lotus::Routing::Resource]
    #
    # @since 0.1.0
    #
    # @see Lotus::Routing::Resource
    # @see Lotus::Routing::Resource::Action
    # @see Lotus::Routing::Resource::Options
    #
    # @example Default usage
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity'
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+-------------------+----------+----------------+
    #   # | Verb   | Path           | Action            | Name     | Named Route    |
    #   # +--------+----------------+-------------------+----------+----------------+
    #   # | GET    | /identity      | Identity::Show    | :show    | :identity      |
    #   # | GET    | /identity/new  | Identity::New     | :new     | :new_identity  |
    #   # | POST   | /identity      | Identity::Create  | :create  | :identity      |
    #   # | GET    | /identity/edit | Identity::Edit    | :edit    | :edit_identity |
    #   # | PATCH  | /identity      | Identity::Update  | :update  | :identity      |
    #   # | DELETE | /identity      | Identity::Destroy | :destroy | :identity      |
    #   # +--------+----------------+-------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :only
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [:show, :new, :create]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+------------------+----------+----------------+
    #   # | Verb   | Path           | Action           | Name     | Named Route    |
    #   # +--------+----------------+------------------+----------+----------------+
    #   # | GET    | /identity      | Identity::Show   | :show    | :identity      |
    #   # | GET    | /identity/new  | Identity::New    | :new     | :new_identity  |
    #   # | POST   | /identity      | Identity::Create | :create  | :identity      |
    #   # +--------+----------------+------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :except
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', except: [:edit, :update, :destroy]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+----------------+------------------+----------+----------------+
    #   # | Verb   | Path           | Action           | Name     | Named Route    |
    #   # +--------+----------------+------------------+----------+----------------+
    #   # | GET    | /identity      | Identity::Show   | :show    | :identity      |
    #   # | GET    | /identity/new  | Identity::New    | :new     | :new_identity  |
    #   # | POST   | /identity      | Identity::Create | :create  | :identity      |
    #   # +--------+----------------+------------------+----------+----------------+
    #
    #
    #
    # @example Additional single routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [] do
    #       member do
    #         patch 'activate'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+--------------------+------+--------------------+
    #   # | Verb   | Path               | Action             | Name | Named Route        |
    #   # +--------+--------------------+--------------------+------+--------------------+
    #   # | PATCH  | /identity/activate | Identity::Activate |      | :activate_identity |
    #   # +--------+--------------------+--------------------+------+--------------------+
    #
    #
    #
    # @example Additional collection routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resource 'identity', only: [] do
    #       collection do
    #         get 'keys'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+----------------+----------------+------+----------------+
    #   # | Verb | Path           | Action         | Name | Named Route    |
    #   # +------+----------------+----------------+------+----------------+
    #   # | GET  | /identity/keys | Identity::Keys |      | :keys_identity |
    #   # +------+----------------+----------------+------+----------------+
    def resource(name, options = {}, &blk)
      Routing::Resource.new(self, name, options.merge(separator: @router.action_separator), &blk)
    end

    # Defines a set of named routes for a plural RESTful resource.
    # It has a built-in integration for Lotus::Controller.
    #
    # @param name [String] the name of the resource
    # @param options [Hash] a set of options to customize the routes
    # @option options [Array<Symbol>] :only a subset of the default routes
    #   that we want to generate
    # @option options [Array<Symbol>] :except prevent the given routes to be
    #   generated
    # @param blk [Proc] a block of code to generate additional routes
    #
    # @return [Lotus::Routing::Resources]
    #
    # @since 0.1.0
    #
    # @see Lotus::Routing::Resources
    # @see Lotus::Routing::Resources::Action
    # @see Lotus::Routing::Resource::Options
    #
    # @example Default usage
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles'
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+-------------------+----------+----------------+
    #   # | Verb   | Path               | Action            | Name     | Named Route    |
    #   # +--------+--------------------+-------------------+----------+----------------+
    #   # | GET    | /articles          | Articles::Index   | :index   | :articles      |
    #   # | GET    | /articles/:id      | Articles::Show    | :show    | :articles      |
    #   # | GET    | /articles/new      | Articles::New     | :new     | :new_articles  |
    #   # | POST   | /articles          | Articles::Create  | :create  | :articles      |
    #   # | GET    | /articles/:id/edit | Articles::Edit    | :edit    | :edit_articles |
    #   # | PATCH  | /articles/:id      | Articles::Update  | :update  | :articles      |
    #   # | DELETE | /articles/:id      | Articles::Destroy | :destroy | :articles      |
    #   # +--------+--------------------+-------------------+----------+----------------+
    #
    #
    #
    # @example Limit the generated routes with :only
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [:index]
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+-----------+-----------------+--------+-------------+
    #   # | Verb | Path      | Action          | Name   | Named Route |
    #   # +------+-----------+-----------------+--------+-------------+
    #   # | GET  | /articles | Articles::Index | :index | :articles   |
    #   # +------+-----------+-----------------+--------+-------------+
    #
    #
    #
    # @example Limit the generated routes with :except
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', except: [:edit, :update]
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+--------------------+-------------------+----------+----------------+
    #   # | Verb   | Path               | Action            | Name     | Named Route    |
    #   # +--------+--------------------+-------------------+----------+----------------+
    #   # | GET    | /articles          | Articles::Index   | :index   | :articles      |
    #   # | GET    | /articles/:id      | Articles::Show    | :show    | :articles      |
    #   # | GET    | /articles/new      | Articles::New     | :new     | :new_articles  |
    #   # | POST   | /articles          | Articles::Create  | :create  | :articles      |
    #   # | DELETE | /articles/:id      | Articles::Destroy | :destroy | :articles      |
    #   # +--------+--------------------+-------------------+----------+----------------+
    #
    #
    #
    # @example Additional single routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [] do
    #       member do
    #         patch 'publish'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +--------+-----------------------+-------------------+------+-------------------+
    #   # | Verb   | Path                  | Action            | Name | Named Route       |
    #   # +--------+-----------------------+-------------------+------+-------------------+
    #   # | PATCH  | /articles/:id/publish | Articles::Publish |      | :publish_articles |
    #   # +--------+-----------------------+-------------------+------+-------------------+
    #
    #
    #
    # @example Additional collection routes
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     resources 'articles', only: [] do
    #       collection do
    #         get 'search'
    #       end
    #     end
    #   end
    #
    #   # It generates:
    #   #
    #   # +------+------------------+------------------+------+------------------+
    #   # | Verb | Path             | Action           | Name | Named Route      |
    #   # +------+------------------+------------------+------+------------------+
    #   # | GET  | /articles/search | Articles::Search |      | :search_articles |
    #   # +------+------------------+------------------+------+------------------+
    def resources(name, options = {}, &blk)
      Routing::Resources.new(self, name, options.merge(separator: @router.action_separator), &blk)
    end

    # Mount a Rack application at the specified path.
    # All the requests starting with the specified path, will be forwarded to
    # the given application.
    #
    # All the other methods (eg #get) support callable objects, but they
    # restrict the range of the acceptable HTTP verb. Mounting an application
    # with #mount doesn't apply this kind of restriction at the router level,
    # but let the application to decide.
    #
    # @param app [#call] a class or an object that responds to #call
    # @param options [Hash] the options to customize the mount
    # @option options [:at] the relative path where to mount the app
    #
    # @since 0.1.1
    #
    # @example Basic usage
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     mount Api::App.new, at: '/api'
    #   end
    #
    #   # Requests:
    #   #
    #   # GET  /api          # => 200
    #   # GET  /api/articles # => 200
    #   # POST /api/articles # => 200
    #   # GET  /api/unknown  # => 404
    #
    # @example Difference between #get and #mount
    #   require 'lotus/router'
    #
    #   Lotus::Router.new do
    #     get '/rack1',      to: RackOne.new
    #     mount RackTwo.new, at: '/rack2'
    #   end
    #
    #   # Requests:
    #   #
    #   # # /rack1 will only accept GET
    #   # GET  /rack1        # => 200 (RackOne.new)
    #   # POST /rack1        # => 405
    #   #
    #   # # /rack2 accepts all the verbs and delegate the decision to RackTwo
    #   # GET  /rack2        # => 200 (RackTwo.new)
    #   # POST /rack2        # => 200 (RackTwo.new)
    #
    # @example Types of mountable applications
    #   require 'lotus/router'
    #
    #   class RackOne
    #     def self.call(env)
    #     end
    #   end
    #
    #   class RackTwo
    #     def call(env)
    #     end
    #   end
    #
    #   class RackThree
    #     def call(env)
    #     end
    #   end
    #
    #   module Dashboard
    #     class Index
    #       def call(env)
    #       end
    #     end
    #   end
    #
    #   Lotus::Router.new do
    #     mount RackOne,                             at: '/rack1'
    #     mount RackTwo,                             at: '/rack2'
    #     mount RackThree.new,                       at: '/rack3'
    #     mount ->(env) {[200, {}, ['Rack Four']]},  at: '/rack4'
    #     mount 'dashboard#index',                   at: '/dashboard'
    #   end
    #
    #   # 1. RackOne is used as it is (class), because it respond to .call
    #   # 2. RackTwo is initialized, because it respond to #call
    #   # 3. RackThree is used as it is (object), because it respond to #call
    #   # 4. That Proc is used as it is, because it respond to #call
    #   # 5. That string is resolved as Dashboard::Index (Lotus::Controller)
    def mount(app, options)
      @router.mount(app, options)
    end

    # Resolve the given Rack env to a registered endpoint and invoke it.
    #
    # @param env [Hash] a Rack env instance
    #
    # @return [Rack::Response, Array]
    #
    # @since 0.1.0
    def call(env)
      @router.call(env)
    end

    # Generate an relative URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param route [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Lotus::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/login', to: 'sessions#new',    as: :login
    #   router.get '/:name', to: 'frameworks#show', as: :framework
    #
    #   router.path(:login)                          # => "/login"
    #   router.path(:login, return_to: '/dashboard') # => "/login?return_to=%2Fdashboard"
    #   router.path(:framework, name: 'router')      # => "/router"
    def path(route, *args)
      @router.path(route, *args)
    end

    # Generate a URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param route [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Lotus::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new(scheme: 'https', host: 'lotusrb.org')
    #   router.get '/login', to: 'sessions#new', as: :login
    #   router.get '/:name', to: 'frameworks#show', as: :framework
    #
    #   router.url(:login)                          # => "https://lotusrb.org/login"
    #   router.url(:login, return_to: '/dashboard') # => "https://lotusrb.org/login?return_to=%2Fdashboard"
    #   router.url(:framework, name: 'router')      # => "https://lotusrb.org/router"
    def url(route, *args)
      @router.url(route, *args)
    end

    # Returns an routes inspector
    #
    # @since 0.2.0
    #
    # @see Lotus::Routing::RoutesInspector
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new do
    #     get    '/',       to: 'home#index'
    #     get    '/login',  to: 'sessions#new',     as: :login
    #     post   '/login',  to: 'sessions#create'
    #     delete '/logout', to: 'sessions#destroy', as: :logout
    #   end
    #
    #   puts router.inspector
    #     # =>        GET, HEAD  /                        Home::Index
    #          login  GET, HEAD  /login                   Sessions::New
    #                 POST       /login                   Sessions::Create
    #          logout GET, HEAD  /logout                  Sessions::Destroy
    def inspector
      require 'lotus/routing/routes_inspector'
      Routing::RoutesInspector.new(@router.routes)
    end
  end
end
