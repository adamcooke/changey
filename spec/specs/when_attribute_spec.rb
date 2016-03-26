require 'spec_helper'

describe "when_attribute()" do

  it "should raise an error when there is no change state" do
    expect { User.when_attribute(:name) }.to raise_error(Changey::DSL::MissingChangeValue)
  end

  it "should raise an error when there is no trigger block" do
    expect { User.when_attribute(:name, :changes_from => nil) }.to raise_error(Changey::DSL::MissingBlock)
  end

  it "should store the tracked attribute and anything from its block" do
    track = User.when_attribute(:name, :changes_from => nil) do
      validate :nothing
      before_save :nothing
      after_save :nothing
      after_commit :nothing
    end
    expect(track).to be_a(Changey::Track)
    expect(track.validates).to_not be_empty
    expect(track.validates.first).to eq :nothing
    expect(User.changey_tracks.first).to eq track
  end

end
