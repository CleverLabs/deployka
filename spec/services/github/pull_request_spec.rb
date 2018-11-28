# frozen_string_literal: true

require "rails_helper"

describe Github::PullRequest do
  subject { described_class.new("rails/rails", 4) }

  around(:each) do |example|
    VCR.use_cassette("github_pullrequest") do
      example.run
    end
  end

  describe "#title" do
    it "receives title from octokit object" do
      expect(subject.title).to eql("This change fixes to_json serialization")
    end
  end
end
