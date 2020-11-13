# frozen_string_literal: true

require 'spec_helper'

describe 'decisions' do
  it 'should run when it changes from known value to anything' do
    track = Changey::Track.new(:name, :from, 'Adam')
    expect(track.run?(User.create_with_name_change('Adam', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', nil))).to be true
    expect(track.run?(User.create_with_name_change('Adam', 'Steve'))).to be true
  end

  it 'should run when it changes to known value from anything' do
    track = Changey::Track.new(:name, :to, 'Steve')
    expect(track.run?(User.create_with_name_change('Adam', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', nil))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Charlotte'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Steve'))).to be true
    expect(track.run?(User.create_with_name_change('Joe', 'Steve'))).to be true
  end

  it 'should run when it changes from known value to known value' do
    track = Changey::Track.new(:name, :from, 'Adam', 'Michael')
    expect(track.run?(User.create_with_name_change('Adam', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', nil))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Steve'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Michael'))).to be true
    expect(track.run?(User.create_with_name_change('Joe', 'Michael'))).to be false
  end

  it 'should run when it changes to known value from known value' do
    track = Changey::Track.new(:name, :to, 'George', 'Adam')
    expect(track.run?(User.create_with_name_change('Adam', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', nil))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Steve'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'George'))).to be true
  end

  it 'should run when it changes from one of an array of known vaues' do
    track = Changey::Track.new(:name, :from, %w[Adam Eve])
    expect(track.run?(User.create_with_name_change('Adam', 'George'))).to be true
    expect(track.run?(User.create_with_name_change('Eve', 'Polly'))).to be true
    expect(track.run?(User.create_with_name_change('Polly', 'Eve'))).to be false
  end

  it 'should run when it changes to one of an array of known vaues' do
    track = Changey::Track.new(:name, :to, %w[Adam Eve])
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be true
    expect(track.run?(User.create_with_name_change('Polly', 'Eve'))).to be true
    expect(track.run?(User.create_with_name_change('Polly', 'Michael'))).to be false
  end

  it 'should run when it changes from one of an array of known vaues to one of an array of know values' do
    track = Changey::Track.new(:name, :from, %w[Adam Eve], %w[Martin Sarah])
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Polly', 'Eve'))).to be false
    expect(track.run?(User.create_with_name_change('Polly', 'Sarah'))).to be false
    expect(track.run?(User.create_with_name_change('Adam', 'Martin'))).to be true
    expect(track.run?(User.create_with_name_change('Eve', 'Martin'))).to be true
    expect(track.run?(User.create_with_name_change('Eve', 'Sarah'))).to be true
  end

  it 'should run when it changes from something that matches a regex' do
    track = Changey::Track.new(:name, :from, /\AAB123\z/)
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Polly', 'Eve'))).to be false
    expect(track.run?(User.create_with_name_change('AB123', 'Eve'))).to be true
  end

  it 'should run when it changes to something that matches a regex' do
    track = Changey::Track.new(:name, :to, /\AP/i)
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Eve', 'Michael'))).to be false
    expect(track.run?(User.create_with_name_change('Eve', 'Polly'))).to be true
    expect(track.run?(User.create_with_name_change('Peter', 'Paul'))).to be true
  end

  it 'should run when it changes from something that results in a proc returning true' do
    track = Changey::Track.new(:name, :from, proc { |value| value == 'Lisa' })
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be false
    expect(track.run?(User.create_with_name_change('Lisa', 'Maggie'))).to be true
  end

  it 'should run when it changes from anything' do
    track = Changey::Track.new(:name, :from, :anything)
    expect(track.run?(User.create_with_name_change('George', 'Adam'))).to be true
    expect(track.run?(User.create_with_name_change(nil, 'Adam'))).to be true
    expect(track.run?(User.create_with_name_change('Adam', nil))).to be true
    expect(track.run?(User.create_with_name_change('Lisa', 'Maggie'))).to be true
  end
end
