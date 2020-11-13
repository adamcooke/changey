# frozen_string_literal: true

require 'spec_helper'

describe 'callbacks' do
  before(:all) do
    class AnotherUser < ActiveRecord::Base

      attr_accessor :last_callback_called

      self.table_name = 'users'

    end
  end

  before(:each) do
    AnotherUser.reset_changey!
  end

  it 'should call validation callbacks when suspended_at is changed/set' do
    AnotherUser.when_attribute :suspended_at, changes_from: nil do
      validate do
        self.last_callback_called = 'validate'
      end
    end
    user = AnotherUser.create!(suspended_at: 2.minutes.from_now)
    expect(user.last_callback_called).to eq 'validate'
  end

  it 'should call before save callbacks when suspended_at is changed/set' do
    AnotherUser.when_attribute :suspended_at, changes_from: nil do
      before_save do
        self.last_callback_called = 'before_save'
      end
    end
    user = AnotherUser.create!(suspended_at: 2.minutes.from_now)
    expect(user.last_callback_called).to eq 'before_save'
  end

  it 'should call after save callbacks when suspended_at is changed/set' do
    AnotherUser.when_attribute :suspended_at, changes_from: nil do
      after_save do
        self.last_callback_called = 'after_save'
      end
    end
    user = AnotherUser.create!(suspended_at: 2.minutes.from_now)
    expect(user.last_callback_called).to eq 'after_save'
  end

  it 'should call after commit callbacks when suspended_at is changed/set' do
    AnotherUser.when_attribute :suspended_at, changes_from: nil do
      after_commit do
        self.last_callback_called = 'after_commit'
      end
    end
    user = AnotherUser.create!(suspended_at: 2.minutes.from_now)
    expect(user.last_callback_called).to eq 'after_commit'
  end
end
