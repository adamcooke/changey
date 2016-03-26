module Changey
  class BlockDSL
    def initialize(track)
      @track = track
    end

    def validate(name = nil, &block)
      @track.validates << (block || name)
    end

    def before_save(name = nil, &block)
      @track.before_saves << (block || name)
    end

    def after_save(name = nil, &block)
      @track.after_saves << (block || name)
    end

    def after_commit(name = nil, &block)
      @track.after_commits << (block || name)
    end
  end
end
