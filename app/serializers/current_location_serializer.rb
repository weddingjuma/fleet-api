class CurrentLocationSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :sync_user,
             :date,
             :locationDetail
end
