RSpec.configure do |config|
  config.before(:example) do
    @json_header = {
      ACCEPT: 'application/json', # This is what Rails 4 accepts
      HTTP_ACCEPT: 'application/json', # This is what Rails 3 accepts
      CONTENT_TYPE: 'application/json'
    }

    def token_header(token)
      @json_header.merge(Authorization: "Token token=#{token}")
    end
  end
end
