class UserSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user,
             :roles
end
