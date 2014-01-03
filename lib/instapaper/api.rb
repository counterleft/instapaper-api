require 'faraday'
require 'simple_oauth'
require 'addressable/uri'

module Instapaper
  class API
    BASE_URI = "https://www.instapaper.com"

    attr_writer :http_client

    def initialize(oauth_key, oauth_secret, username, password, http_client = Faraday.new)
      @oauth_options = { consumer_key: oauth_key, consumer_secret: oauth_secret }
      @oauth_creds = { username: username, password: password }
      @http_client = http_client
    end

    def get_access_token
      path = "/api/1/oauth/access_token"
      options = {
        x_auth_username: @oauth_creds[:username],
        x_auth_password: @oauth_creds[:password],
        x_auth_mode: "client_auth",
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
      response = call("/api/1/bookmarks/list", options)
      response.body
    end

    def add_bookmark(options = {})
      response = call("/api/1/bookmarks/add", options)
      response.body
    end

    def delete_bookmark(bookmark_id)
      response = call("/api/1/bookmarks/delete", bookmark_id: bookmark_id)
      response.body
    end

    def star_bookmark(bookmark_id)
      response = call("/api/1/bookmarks/star", bookmark_id: bookmark_id)
      response.body
    end

    def unstar_bookmark(bookmark_id)
      response = call("/api/1/bookmarks/unstar", bookmark_id: bookmark_id)
      response.body
    end

    def archive_bookmark(bookmark_id)
      response = call("/api/1/bookmarks/archive", bookmark_id: bookmark_id)
      response.body
    end

    def unarchive_bookmark(bookmark_id)
      response = call("/api/1/bookmarks/unarchive", bookmark_id: bookmark_id)
      response.body
    end

    def move_bookmark(bookmark_id, folder_id)
      response = call("/api/1/bookmarks/move", bookmark_id: bookmark_id, folder_id: folder_id)
      response.body
    end

    def get_bookmark_text(bookmark_id)
      response = call("/api/1/bookmarks/get_text", bookmark_id: bookmark_id)
      response.body
    end

    def list_folders
      response = call("/api/1/folders/list")
      response.body
    end

    def add_folder(title)
      response = call("/api/1/folders/add", title: title)
      response.body
    end

    def delete_folder(folder_id)
      response = call("/api/1/folders/delete", folder_id: folder_id)
      response.body
    end

    def set_folder_order(order)
      value = []
      order.each { |folder_id, position| value.push("#{folder_id}:#{position}") }
      response = call("/api/1/folders/set_order", order: value.join(","))
      response.body
    end

    private

    def parse_authenticate_body(body)
      uri = Addressable::URI.new(query: body)
      { token: uri.query_values["oauth_token"], token_secret: uri.query_values["oauth_token_secret"] }
    end

    def call(path, options = {})
      get_access_token unless authenticated?
      send_request(path, options)
    end

    def send_request(path, options = {})
      url = "#{BASE_URI}#{path}"
      oauth_header = SimpleOAuth::Header.new(:post, url, options, @oauth_options)
      @http_client.post do |r|
        r.url url
        r.body = options
        r.headers["Authorization"] = oauth_header.to_s
      end
    end
  end

  class AuthenticationError < StandardError
  end
end
