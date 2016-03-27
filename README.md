# Changey

Changey works with Active Record and allows you to trigger certain callbacks based on the changes of attributes on the model. For example, when a user is given an `suspended_at` timestamp, you may wish to enforce other validations or run callbacks.

```ruby
class User < ActiveRecord::Base

  when_attribute :suspended_at, :changes_from => nil do
    validate do
      if suspended_at < Time.now
        errors.add :suspended_at, "cannot be set in the past"
      end
    end

    after_commit do |was, now|
      UserMailer.suspension_notice(self).deliver_later
    end
  end

end
```

## Installation

Just add the gem to your Gemfile.

```ruby
gem 'changey', '>= 0.0.0'
```

## Usage

To choose what changes you wish to track, you call a `when_attribute` method and provide it with some expectations. Here's an example of some of the expectations you might work with.

```ruby
# Whenever the name attribute changes from 'Adam' to any other value
when_attribute :name, :changes_from => "Adam"

# Whenever the name attribute changes to 'Adam' from any other value
when_attribute :name, :changes_to => "Adam"

# Whenever the name attribute changes from 'Adam' to 'Michael'
when_attribute :name, :changes_from => 'Adam', :to => 'Michael'

# Whenever the name attribute changes to 'Michael' from 'Adam' (same as above)
when_attribute :name, :changes_to => 'Michael', :from => 'Adam'
```

These examples show all your expectation values as strings however you can also use Arrays, Regular Expressions & Procs in place of these. Here's some examples:

```ruby
# Whenever the name attribute changes from 'Adam' or 'Eve' to any value
when_attribute :name, :changes_from => ['Adam', 'Eve']

# Whenever the name attribute changes from a name beginning with an P
when_attribute :name, :changes_from => /\A[P]/i

# Whenever the name attribute changes to something that passed an external check
when_attribute :name, :changes_to => Proc.new { |value| SomeCheck.check(value) }
```

In addition to provide your expectations, you also need to provide a block which allows you to choose the behaviour to be executed when the change occurs.

The callbacks which are supported within the `when_attribute` block are:

* `validate` - called as part of the validation.
* `before_save` - called after validation before the record is saved.
* `after_save` - called after the save has been completed.
* `after_commit` - called after the record has been committed.

When calling one of these types of callback you can either provide a block or the name of a method to execute. For example:

```ruby
when_attribute :suspended_at, :changes_from => nil do
  validate :do_some_validation
end
```

When you provide a block, you'll be provided with the previous and current value of the attribute which you are tracking. This is espically useful in an `after_commit` callback where Active Record's tracking of attributes has been reset already.

```ruby
when_attribute :suspended_at, :changes_to => nil do
  after_commit do |time_originally_suspended, now|
    UserMailer.unsuspension(self, time_originally_suspended).deliver_later
  end
end
```

