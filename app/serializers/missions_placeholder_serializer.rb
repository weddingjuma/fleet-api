class MissionsPlaceholderSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :sync_user,
             :date

end
