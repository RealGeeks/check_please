module CheckPlease

  module Error
    # Rather than having a common error superclass, I'm taking a cue from
    # https://avdi.codes/exceptionalruby and tagging things with a module
    # instead....
  end

  class InvalidFlag < ArgumentError
    include CheckPlease::Error
  end

end
