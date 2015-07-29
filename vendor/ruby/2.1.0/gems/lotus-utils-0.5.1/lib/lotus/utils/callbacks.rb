require 'lotus/utils/deprecation'

module Lotus
  module Utils
    # Before and After callbacks
    #
    # @since 0.1.0
    # @private
    module Callbacks
      # Series of callbacks to be executed
      #
      # @since 0.1.0
      # @private
      class Chain
        # Return a new chain
        #
        # @return [Lotus::Utils::Callbacks::Chain]
        #
        # @since 0.2.0
        def initialize
          @chain = Array.new
        end

        # Appends the given callbacks to the end of the chain.
        #
        # @param callbacks [Array] one or multiple callbacks to append
        # @param block [Proc] an optional block to be appended
        #
        # @return [void]
        #
        # @raise [RuntimeError] if the object was previously frozen
        #
        # @see #prepend
        # @see #run
        # @see Lotus::Utils::Callbacks::Callback
        # @see Lotus::Utils::Callbacks::MethodCallback
        # @see Lotus::Utils::Callbacks::Chain#freeze
        #
        # @since 0.3.4
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #
        #   # Append a Proc to be used as a callback, it will be wrapped by `Callback`
        #   # The optional argument(s) correspond to the one passed when invoked the chain with `run`.
        #   chain.append { Authenticator.authenticate! }
        #   chain.append { |params| ArticleRepository.find(params[:id]) }
        #
        #   # Append a Symbol as a reference to a method name that will be used as a callback.
        #   # It will wrapped by `MethodCallback`
        #   # If the #notificate method accepts some argument(s) they should be passed when `run` is invoked.
        #   chain.append :notificate
        def append(*callbacks, &block)
          callables(callbacks, block).each do |c|
            @chain.push(c)
          end

          @chain.uniq!
        end

        # @since 0.1.0
        # @deprecated Use Lotus::Utils::Callbacks::Chain#append as it has the
        #   same effect, but it's more consistent with the new API.
        #
        # @see Lotus::Utils::Callbacks::Chain#append
        def add(*callbacks, &blk)
          Utils::Deprecation.new("Lotus::Utils::Callbacks::Chain#add is deprecated, use #append instead.")
          append(*callbacks, &blk)
        end

        # Prepends the given callbacks to the beginning of the chain.
        #
        # @param callbacks [Array] one or multiple callbacks to add
        # @param block [Proc] an optional block to be added
        #
        # @return [void]
        #
        # @raise [RuntimeError] if the object was previously frozen
        #
        # @see #append
        # @see #run
        # @see Lotus::Utils::Callbacks::Callback
        # @see Lotus::Utils::Callbacks::MethodCallback
        # @see Lotus::Utils::Callbacks::Chain#freeze
        #
        # @since 0.3.4
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #
        #   # Add a Proc to be used as a callback, it will be wrapped by `Callback`
        #   # The optional argument(s) correspond to the one passed when invoked the chain with `run`.
        #   chain.prepend { Authenticator.authenticate! }
        #   chain.prepend { |params| ArticleRepository.find(params[:id]) }
        #
        #   # Add a Symbol as a reference to a method name that will be used as a callback.
        #   # It will wrapped by `MethodCallback`
        #   # If the #notificate method accepts some argument(s) they should be passed when `run` is invoked.
        #   chain.prepend :notificate
        def prepend(*callbacks, &block)
          callables(callbacks, block).each do |c|
            @chain.unshift(c)
          end

          @chain.uniq!
        end

        # Runs all the callbacks in the chain.
        # The only two ways to stop the execution are: `raise` or `throw`.
        #
        # @param context [Object] the context where we want the chain to be invoked.
        # @param args [Array] the arguments that we want to pass to each single callback.
        #
        # @since 0.1.0
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   class Action
        #     private
        #     def authenticate!
        #     end
        #
        #     def set_article(params)
        #     end
        #   end
        #
        #   action = Action.new
        #   params = Hash[id: 23]
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #   chain.add :authenticate!, :set_article
        #
        #   chain.run(action, params)
        #
        #   # `params` will only be passed as #set_article argument, because it has an arity greater than zero
        #
        #
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #
        #   chain.add do
        #     # some authentication logic
        #   end
        #
        #   chain.add do |params|
        #     # some other logic that requires `params`
        #   end
        #
        #   chain.run(action, params)
        #
        #   Those callbacks will be invoked within the context of `action`.
        def run(context, *args)
          @chain.each do |callback|
            callback.call(context, *args)
          end
        end

        # It freezes the object by preventing further modifications.
        #
        # @since 0.2.0
        #
        # @see http://ruby-doc.org/core/Object.html#method-i-freeze
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   chain = Lotus::Utils::Callbacks::Chain.new
        #   chain.freeze
        #
        #   chain.frozen?  # => true
        #
        #   chain.add :authenticate! # => RuntimeError
        def freeze
          super
          @chain.freeze
        end


        private

        def callables(callbacks, block)
          callbacks.push(block) if block
          callbacks.map { |c| Factory.fabricate(c) }
        end

      end

      # Callback factory
      #
      # @since 0.1.0
      # @private
      class Factory
        # Instantiates a `Callback` according to if it responds to #call.
        #
        # @param callback [Object] the object that needs to be wrapped
        #
        # @return [Callback, MethodCallback]
        #
        # @since 0.1.0
        #
        # @example
        #   require 'lotus/utils/callbacks'
        #
        #   callable = Proc.new{} # it responds to #call
        #   method   = :upcase    # it doesn't responds to #call
        #
        #   Lotus::Utils::Callbacks::Factory.fabricate(callable).class
        #     # => Lotus::Utils::Callbacks::Callback
        #
        #   Lotus::Utils::Callbacks::Factory.fabricate(method).class
        #     # => Lotus::Utils::Callbacks::MethodCallback
        def self.fabricate(callback)
          if callback.respond_to?(:call)
            Callback.new(callback)
          else
            MethodCallback.new(callback)
          end
        end
      end

      # Proc callback
      # It wraps an object that responds to #call
      #
      # @since 0.1.0
      # @private
      class Callback
        attr_reader :callback

        # Initialize by wrapping the given callback
        #
        # @param callback [Object] the original callback that needs to be wrapped
        #
        # @return [Callback] self
        #
        # @since 0.1.0
        #
        def initialize(callback)
          @callback = callback
        end

        # Executes the callback within the given context and passing the given arguments.
        #
        # @param context [Object] the context within we want to execute the callback.
        # @param args [Array] an array of arguments that will be available within the execution.
        #
        # @return [void, Object] It may return a value, it depends on the callback.
        #
        # @since 0.1.0
        #
        # @see Lotus::Utils::Callbacks::Chain#run
        def call(context, *args)
          context.instance_exec(*args, &callback)
        end
      end

      # Method callback
      # It wraps a symbol or a string representing a method name that is implemented by the context within it will be called.
      #
      # @since 0.1.0
      # @private
      class MethodCallback < Callback
        # Executes the callback within the given context and eventually passing the given arguments.
        # Those arguments will be passed according to the arity of the target method.
        #
        # @param context [Object] the context within we want to execute the callback.
        # @param args [Array] an array of arguments that will be available within the execution.
        #
        # @return [void, Object] It may return a value, it depends on the callback.
        #
        # @since 0.1.0
        #
        # @see Lotus::Utils::Callbacks::Chain#run
        def call(context, *args)
          method = context.method(callback)

          if method.parameters.any?
            method.call(*args)
          else
            method.call
          end
        end

        def hash
          callback.hash
        end

        def eql?(other)
          hash == other.hash
        end
      end
    end
  end
end
