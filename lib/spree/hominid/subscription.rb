module Spree::Hominid
  class Subscription
    def initialize(user)
      @user       = user
      @changes    = user.changes.dup
      @interface  = Config.list
    end

    def subscribe
      @interface.subscribe(Config.preferred_list_name, @user.email, merge_vars) if @interface && @user.subscribed
    end

    def unsubscribe
      @interface.unsubscribe(Config.preferred_list_name, @user.email) if @interface
    end

    def needs_update?
      @user.subscribed && attributes_changed?
    end

    def sync(&block)
      block.call

      if @changes[:subscribed] && !@user.subscribed
        unsubscribe
      else
        subscribe
      end
    end

  private
    def attributes_changed?
      Config.preferred_merge_vars.values.any? do |attr|
        @user.send("#{attr}_changed?")
      end
    end

    def merge_vars
      array = Config.preferred_merge_vars.except('EMAIL').map do |tag, method|
        [tag, @user.send(method)]
      end

      Hash[array]
    end
  end
end
