class TrackSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :date,
             :locationDetails
end
