require 'changey/track'
require 'changey/block_dsl'

module Changey
  module DSL

    class InvalidDSL < StandardError; end
    class MissingChangeValue < InvalidDSL; end
    class MissingBlock < InvalidDSL; end

    def self.load(load_into)
      load_into.extend ClassMethods
    end

    module ClassMethods
      def changey_tracks
        @changey_tracks ||= []
      end

      def reset_changey!
        @changey_tracks = nil
      end

      def when_attribute(attribute_name, options = {}, &block)
        if self.changey_tracks.empty?
          include InstanceMethods
        end

        unless options.has_key?(:changes_from) || options.has_key?(:changes_to)
          raise MissingChangeValue, "Attribute #{attribute_name} must specify a 'changes_to' or a 'changes_from' value"
        end

        unless block_given?
          raise MissingBlock, "Attribute #{attribute_name} must specify a block"
        end

        track = Track.new(attribute_name)
        track.direction = options.has_key?(:changes_from) ? :from : :to
        track.expected_value = options.has_key?(:changes_from) ? options[:changes_from] : options[:changes_to]

        if options.has_key?(:to) || options.has_key?(:from)
          track.expected_other_value = options.has_key?(:to) ? options[:to] : options[:from]
        end

        BlockDSL.new(track).instance_eval(&block)
        self.changey_tracks << track
        track
      end
    end

    module InstanceMethods

      def self.included(base)
        base.before_validation  { set_changey_tracks                    }
        base.validate           { run_changey_callbacks(:validate)      }
        base.before_save        { run_changey_callbacks(:before_save)   }
        base.after_save         { run_changey_callbacks(:after_save)    }
        base.after_commit       { run_changey_callbacks(:after_commit)  }
      end

      private def set_changey_tracks
        @changey_tracks_to_run = self.class.changey_tracks.select { |t| t.run?(self) }.each_with_object({}) do |track, hash|
          hash[track] = [send("#{track.attribute}_was"), send(track.attribute)]
        end
      end

      private def clear_changey_tracks
        @changey_tracks_to_run = nil
      end

      private def run_changey_callbacks(event)
        if @changey_tracks_to_run
          @changey_tracks_to_run.each do |track, (was, now)|
            callbacks = track.send(event.to_s.pluralize)
            callbacks.each do |callback|
              if callback.is_a?(Proc)
                instance_exec(was, now, &callback)
              elsif callback.is_a?(Symbol)
                send(callback)
              end
            end
          end
        end
      end
    end

  end
end
