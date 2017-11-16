class Api::FilteredContactsController < Api::FilteredController
  include BatchOperationResource

  PERMITTED_BATCH_OPERATION_TYPES = [
    "BatchOperation::CalloutPopulation",
    "BatchOperation::PhoneCallCreate"
  ]

  private

  def filter_class
    Filter::Resource::Contact
  end

  def permitted_batch_operation_types
    PERMITTED_BATCH_OPERATION_TYPES
  end
end
