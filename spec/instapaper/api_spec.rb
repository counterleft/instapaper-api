require 'simple_oauth'
require 'typhoeus'
require 'instapaper'

describe "Instapaper API" do
  BOOKMARKS_JSON = %![{"type":"meta"},{"type":"user","user_id":12345,"username":"redacted@email.tld","subscription_is_active":"1"},{"type":"bookmark","bookmark_id":190661097,"url":"http:\/\/www.defmacro.org\/ramblings\/fp.html","title":"defmacro - Functional Programming For The Rest of Us","description":"www.defmacro.org","time":1311985243,"starred":"0","private_source":"","hash":"kL5ezMuI","progress":0,"progress_timestamp":0},{"type":"bookmark","bookmark_id":190372127,"url":"http:\/\/robots.thoughtbot.com\/post\/8181879506\/if-you-gaze-into-nil-nil-gazes-also-into-you","title":"giant robots smashing into other giant robots","description":"","time":1311914882,"starred":"0","private_source":"","hash":"dWfH7Iw5","progress":0,"progress_timestamp":0},{"type":"bookmark","bookmark_id":190187751,"url":"http:\/\/robots.thoughtbot.com\/post\/8135270582\/code-review-ruby-and-rails-idioms?utm_source=rubyweekly&utm_medium=email","title":"Code review: Ruby and Rails idioms \u2014 giant robots smashing into other giant robots","description":"robots.thoughtbot.com","time":1311874114,"starred":"0","private_source":"","hash":"ys2iq9YQ","progress":0,"progress_timestamp":0}]!

  before :each do
    @key = ENV['OAUTH_CONSUMER_KEY']
    @secret = ENV['OAUTH_CONSUMER_SECRET']
    @username = ENV['INSTAPAPER_USERNAME']
    @password = ENV['INSTAPAPER_PASSWORD']
    @hydra = Typhoeus::Hydra.new
    @uri = Instapaper::API::BASE_URI
    @api = Instapaper::API.new(@key, @secret, @username,@password)
  end

  it "authenticates a user" do
    @api.get_access_token.should be_true
    @api.authenticated?.should be_true
  end

  it "raises AuthenticationError when oauth is incorrect" do
    key = "wrong"
    secret = "wrong"
    api = Instapaper::API.new(key, secret, @username, @password)
    expect { api.get_access_token }.to raise_error(Instapaper::AuthenticationError)
    api.authenticated?.should be_false
  end

  it "lists bookmarks" do
    response = Typhoeus::Response.new(:code => 200, :body => BOOKMARKS_JSON)
    @hydra.stub(:post, [@uri, "/bookmarks/list"].join).and_return(response)
    @api.hydra = @hydra
    @api.list_bookmarks.should be_equal(response.body)
  end
end