require "spec_helper"

describe "Instapaper API" do
  subject { Instapaper::API.new("key", "secret", "user@name.tld", "password") }

  BOOKMARKS_JSON = %![{"type":"meta"},{"type":"user","user_id":12345,"username":"redacted@email.tld","subscription_is_active":"1"},{"type":"bookmark","bookmark_id":190661097,"url":"http:\/\/www.defmacro.org\/ramblings\/fp.html","title":"defmacro - Functional Programming For The Rest of Us","description":"www.defmacro.org","time":1311985243,"starred":"0","private_source":"","hash":"kL5ezMuI","progress":0,"progress_timestamp":0},{"type":"bookmark","bookmark_id":190372127,"url":"http:\/\/robots.thoughtbot.com\/post\/8181879506\/if-you-gaze-into-nil-nil-gazes-also-into-you","title":"giant robots smashing into other giant robots","description":"","time":1311914882,"starred":"0","private_source":"","hash":"dWfH7Iw5","progress":0,"progress_timestamp":0},{"type":"bookmark","bookmark_id":190187751,"url":"http:\/\/robots.thoughtbot.com\/post\/8135270582\/code-review-ruby-and-rails-idioms?utm_source=rubyweekly&utm_medium=email","title":"Code review: Ruby and Rails idioms \u2014 giant robots smashing into other giant robots","description":"robots.thoughtbot.com","time":1311874114,"starred":"0","private_source":"","hash":"ys2iq9YQ","progress":0,"progress_timestamp":0}]!

  before :each do
    stub_request(:post, "https://www.instapaper.com/api/1/oauth/access_token")
    .with(body: { x_auth_mode: "client_auth", x_auth_password: "password", x_auth_username: "user@name.tld" })
    .to_return(status: 200, body: "oauth_token=token&oauth_token_secret=token_secret" )

    stub_request(:post, "https://www.instapaper.com/api/1/bookmarks/list")
    .to_return(body: BOOKMARKS_JSON)
  end

  it "authenticates a user" do
    expect(subject.get_access_token).to be_true
    expect(subject.authenticated?).to be_true
  end

  it "lists bookmarks" do
    expect(subject.list_bookmarks).to eq(BOOKMARKS_JSON)
  end

  context "when oauth is incorrect" do
    before :each do
      stub_request(:post, "https://www.instapaper.com/api/1/oauth/access_token")
      .with(body: { x_auth_mode: "client_auth", x_auth_password: "password", x_auth_username: "user@name.tld" })
      .to_return(status: 401, body: "Unauthorized")
    end

    it "raises AuthenticationError" do
      expect { subject.get_access_token }.to raise_error(Instapaper::AuthenticationError)
      expect(subject.authenticated?).to be_false
    end
  end
end
