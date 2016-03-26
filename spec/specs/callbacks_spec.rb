require 'spec_helper'

describe "callbacks" do
  before(:all) do
    class AnotherUser < ActiveRecord::Base
      self.table_name = 'users'

      def callbacks_called
        @callbacks_called ||= []
      end

      when_attribute :suspended_at, :changes_from => nil do
        validate do
          callbacks_called << 'validate'
        end

        before_save do
          callbacks_called << 'before_save'
        end

        after_save do
          callbacks_called << 'after_save'
        end

        after_commit do |was, now|
          callbacks_called << "after_commit"
        end
      end

      when_attribute :name, :changes_from => "Adam", :to => "Joe" do
        validate do
          errors.add :name, "cannot be changed from Adam to Joe"
        end
      end
    end
  end

  it "should call validation callbacks when suspended_at is changed/set" do
    user = AnotherUser.create!(:suspended_at => 2.minutes.from_now)
    expect(user.callbacks_called).to include('validate')
  end

  it "should call before save callbacks when suspended_at is changed/set" do
    user = AnotherUser.create!(:suspended_at => 2.minutes.from_now)
    expect(user.callbacks_called).to include('before_save')
  end

  it "should call after save callbacks when suspended_at is changed/set" do
    user = AnotherUser.create!(:suspended_at => 2.minutes.from_now)
    expect(user.callbacks_called).to include('after_save')
  end

  it "should call after commit callbacks when suspended_at is changed/set" do
    user = AnotherUser.create!(:suspended_at => 2.minutes.from_now)
    expect(user.callbacks_called).to include('after_commit')
  end

  it "should be invoked when name changes from somethign to something else" do
    user = AnotherUser.create!(:name => "Adam")
    user.name = "Joe"
    expect { user.save! }.to raise_error ActiveRecord::RecordInvalid
    user.name = "Michael"
    expect { user.save! }.to_not raise_error
  end

end
