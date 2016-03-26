module Changey
  class Railtie < Rails::Railtie

    initializer 'changey.initialize' do
      ActiveSupport.on_load(:active_record) do
        require 'changey/dsl'
        Changey::DSL.load ActiveRecord::Base
      end
    end

  end
end
