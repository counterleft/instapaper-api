require 'typhoeus'
require 'simple_oauth'
require 'addressable/uri'

module Instapaper
  class API
    BASE_URI = "https://www.instapaper.com/api/1"

    attr_writer :hydra

    def initialize(oauth_key, oauth_secret, username, password)
      @oauth_options = {:consumer_key => oauth_key, :consumer_secret => oauth_secret}
      @oauth_creds = {:username => username, :password => password}
      @hydra = Typhoeus::Hydra.new
    end

    def get_access_token
      path = "/oauth/access_token"
      options = {
        :x_auth_username => @oauth_creds[:username],
        :x_auth_password => @oauth_creds[:password],
        :x_auth_mode => "client_auth",
      }

      response = send_request(path, options)

      raise AuthenticationError, response.body unless response.success?

      @oauth_options.merge!(parse_authenticate_body(response.body))
      authenticated?
    end

    def authenticated?
      @oauth_options[:token] && @oauth_options[:token_secret]
    end

    def list_bookmarks(options = {})
      response = call("/bookmarks/list", options)
      response.body
    end

    def add_bookmark(options = {})
      response = call("/bookmarks/add", options)
      response.body
    end

    def delete_bookmark(bookmark_id)
      response = call("/bookmarks/delete", {:bookmark_id => bookmark_id})
      response.body
    end

    def star_bookmark(bookmark_id)
      response = call("/bookmarks/star", {:bookmark_id => bookmark_id})
      response.body
    end

    def unstar_bookmark(bookmark_id)
      response = call("/bookmarks/unstar", {:bookmark_id => bookmark_id})
      response.body
    end

    def archive_bookmark(bookmark_id)
      response = call("/bookmarks/archive", {:bookmark_id => bookmark_id})
      response.body
    end

    def unarchive_bookmark(bookmark_id)
      response = call("/bookmarks/unarchive", {:bookmark_id => bookmark_id})
      response.body
    end

    def move_bookmark(bookmark_id, folder_id)
      response = call("/bookmarks/move", {:bookmark_id => bookmark_id, :folder_id => folder_id})
      response.body
    end

    def get_bookmark_text(bookmark_id)
      response = call("/bookmarks/get_text", {:bookmark_id => bookmark_id})
      response.body
    end

    def list_folders
      response = call("/folders/list")
      response.body
    end

    def add_folder(title)
      response = call("/folders/add", {:title => title})
      response.body
    end

    def delete_folder(folder_id)
      response = call("/folders/delete", {:folder_id => folder_id})
      response.body
    end

    def set_folder_order(order)
      value = []
      order.each { |folder_id, position| value.push("#{folder_id}:#{position}") }
      response = call("/folders/set_order", {:order => value.join(",")})
      response.body
    end

    private

    def parse_authenticate_body(body)
      uri = Addressable::URI.new(:query => body)
      {:token => uri.query_values["oauth_token"], :token_secret => uri.query_values["oauth_token_secret"]}
    end

    def call(path, options = {})
      get_access_token unless authenticated?
      send_request(path, options)
    end

    def send_request(path, options = {})
      uri = [BASE_URI, path].join
      req = Typhoeus::Request.new(uri, :method => :post, :params => options)
      oauth_header = SimpleOAuth::Header.new(req.method, uri, options, @oauth_options)
      req.headers.merge!({"Authorization" => oauth_header.to_s})

      @hydra.queue(req)
      @hydra.run
      req.response
    end
  end

  class AuthenticationError < StandardError
  end
end