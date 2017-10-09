RSpec.configure do |config|
  config.after(:all) do
    @reactor = ::Libuv::Reactor.default
    @reactor.run { |_reactor|
      CouchbaseOrm::Connection.bucket.connection.destroy.then do
        connection = CouchbaseOrm::Connection.bucket.connection
        connection.connect(flush_enabled: true).then do
          begin
            connection.flush.then(proc { |resp|
              resp.callback
            }, proc { |error|
              p 'Error when flushing bucket:'
              p error
            }) #.finally { connection.destroy }
          rescue => error
            p 'Error when connecting to bucket for flushing:'
            p error
            connection.destroy
          end
        end
      end
    }
    sleep 3 # Wait for asynchronous flushing
  end
end
