class MissionSerializer < ActiveModel::Serializer
  attributes :id,
             :company_id,
             :user_id,
             :sync_user,
             :external_ref,
             :name,
             :date,
             :location,
             :address,
             :comment,
             :phone,
             :reference,
             :duration,
             :time_windows,
             :status_type_label,
             :status_type_color

  def status_type_label
    object.mission_status_type.label if object.mission_status_type
  end

  def status_type_color
    object.mission_status_type.color if object.mission_status_type
  end
end
