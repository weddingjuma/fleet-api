RSpec.configure do |config|
  config.before(:suite) do
    Admin.ensure_design_document!
    Company.ensure_design_document!
    User.ensure_design_document!
    Route.ensure_design_document!
    Mission.ensure_design_document!
    MissionAction.ensure_design_document!
    MissionStatusType.ensure_design_document!
    MissionActionType.ensure_design_document!
    MissionEventType.ensure_design_document!
    MissionEventTypeComputeEta.ensure_design_document!
    MissionEventTypeSendSmsApproach.ensure_design_document!
    MissionEventTypeSendSmsDeparture.ensure_design_document!
    MissionsPlaceholder.ensure_design_document!
    UserCurrentLocation.ensure_design_document!
    UserSettings.ensure_design_document!
    UserTrack.ensure_design_document!
    SchemaMigration.ensure_design_document!
    MetaInfo.ensure_design_document!

    # Check and create index type if necessary (iso : populate)
    bucket_name = Mission.bucket.bucket
    index_type = Mission.bucket.n1ql.select('*').from("system:indexes").where("name=\"#{bucket_name}_mission\"").results.first
    if(!index_type)
      # Query type : CREATE INDEX `fleet-dev_mission` ON `fleet-dev`(`company_id`, `sync_user`) WHERE type='mission'
      Mission.bucket.n1ql.create_index("`#{bucket_name}_mission` ON `#{bucket_name}`(`company_id`, `sync_user`) WHERE type='mission'").results.to_a
    end
  end

  config.after(:all) do
    Admin.all.stream { |ob| ob.delete }
    Company.all.stream { |ob| ob.delete }
    User.all.stream { |ob| ob.delete }
    Route.all.stream { |ob| ob.delete }
    Mission.all.stream { |ob| ob.delete }
    MissionAction.all.stream { |ob| ob.delete }
    MissionStatusType.all.stream { |ob| ob.delete }
    MissionActionType.all.stream { |ob| ob.delete }
    MissionEventType.all.stream { |ob| ob.delete }
    MissionEventTypeComputeEta.all.stream { |ob| ob.delete }
    MissionEventTypeSendSmsApproach.all.stream { |ob| ob.delete }
    MissionEventTypeSendSmsDeparture.all.stream { |ob| ob.delete }
    MissionsPlaceholder.all.stream { |ob| ob.delete }
    UserCurrentLocation.all.stream { |ob| ob.delete }
    UserSettings.all.stream { |ob| ob.delete }
    UserTrack.all.stream { |ob| ob.delete }
    SchemaMigration.all.stream { |ob| ob.delete }
    MetaInfo.all.stream { |ob| ob.delete }
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
