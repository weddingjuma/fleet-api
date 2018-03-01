class Workflow
  def initialize(company, options = {})
    status_types = create_mission_status_types(company)
    create_workflow(company, status_types)

    # Associate a default status type to company for new missions
    company.update_attribute(:default_mission_status_type_id, self.class.initial_mission_status(company)&.id) if options[:default]
  end
end
