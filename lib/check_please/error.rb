module CheckPlease

  module Error
    # Rather than having a common error superclass, I'm taking a cue from
    # https://avdi.codes/exceptionalruby and tagging things with a module
    # instead....
  end

  class BehaviorUndefined < ::StandardError
    include CheckPlease::Error
  end

  class DuplicateKeyError < ::IndexError
    include CheckPlease::Error
  end

  class InvalidFlag < ArgumentError
    include CheckPlease::Error
  end

  class InvalidPath < ArgumentError
    include CheckPlease::Error
  end

  class InvalidPathSegment < ArgumentError
    include CheckPlease::Error
  end

  class NoSuchKeyError < ::KeyError
    include CheckPlease::Error
  end

  class TypeMismatchError < ::TypeError
    include CheckPlease::Error
  end

end
