RSpec.configure do |config|
  config.before(:suite) do
    Company.ensure_design_document!
    User.ensure_design_document!
    Mission.ensure_design_document!
  end

  config.after(:all) do
    Company.all.stream { |ob| ob.delete }
    User.all.stream { |ob| ob.delete }
    Mission.all.stream { |ob| ob.delete }
  end

  # config.after(:all) do
  #   @reactor = ::Libuv::Reactor.default
  #   @reactor.run { |_reactor|
  #     CouchbaseOrm::Connection.bucket.connection.destroy.then do
  #       connection = CouchbaseOrm::Connection.bucket.connection
  #       connection.connect(flush_enabled: true).then do
  #         begin
  #           connection.flush.then(proc { |resp|
  #             resp.callback
  #           }, proc { |error|
  #             p 'Error when flushing bucket:'
  #             p error
  #           }) #.finally { connection.destroy }
  #         rescue => error
  #           p 'Error when connecting to bucket for flushing:'
  #           p error
  #           connection.destroy
  #         end
  #       end
  #     end
  #   }
  #   sleep 5 # Wait for asynchronous flushing
  # end
end
