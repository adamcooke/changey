require 'spec_helper'

describe "decisions" do

  before do
    @user = User.create!(:name => "Adam")
  end

  it "should run when it changes from known value to anything" do
    track = Changey::Track.new(:name, :from, 'Adam')
    # No change
    expect(track.run?(@user)).to be false
    # Change to nil
    @user.name = nil
    expect(track.run?(@user)).to be true
    # Change to other string
    @user.name = "Steve"
    expect(track.run?(@user)).to be true
  end

  it "should run when it changes to known value from anything" do
    track = Changey::Track.new(:name, :to, 'Steve')
    # No change
    expect(track.run?(@user)).to be false
    # Change to nil
    @user.name = nil
    expect(track.run?(@user)).to be false
    # Change to other string
    @user.name = "Steve"
    expect(track.run?(@user)).to be true
  end

  it "should run when it changes from known value to known value" do
    track = Changey::Track.new(:name, :from, 'Adam', 'Michael')
    # No change
    expect(track.run?(@user)).to be false
    # Change to nil
    @user.name = nil
    expect(track.run?(@user)).to be false
    # Change to other string
    @user.name = "Steve"
    expect(track.run?(@user)).to be false
    # Change to other string
    @user.name = "Michael"
    expect(track.run?(@user)).to be true
  end

  it "should run when it changes to known value from known value" do
    track = Changey::Track.new(:name, :to, 'George', 'Adam')
    # No change
    expect(track.run?(@user)).to be false
    # Change to nil
    @user.name = nil
    expect(track.run?(@user)).to be false
    # Change to other string
    @user.name = "Steve"
    expect(track.run?(@user)).to be false
    # Change to other string
    @user.name = "George"
    expect(track.run?(@user)).to be true
  end

end
