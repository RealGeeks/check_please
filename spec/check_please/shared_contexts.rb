RSpec.shared_context "complex pair" do
  let(:complex_reference) {
    {
      id:    42,
      name:  "The Answer",
      words: %w[ what do you get when you multiply six by nine ],
      meta:  { foo: "spam", bar: "eggs", yak: "bacon" }
    }
  }
  let(:complex_candidate) {
    {
      id:    42,
      name:  "Charlie",
      #      ^^^^^^^^^
      words: %w[ what do we get when I multiply six by nine dude ],
      #                  ^^          ^                      ^^^^
      meta:  { foo: "foo",              yak: "bacon" }
      #             ^^^^^  ^^^^^^^^^^^^
    }
  }
end
