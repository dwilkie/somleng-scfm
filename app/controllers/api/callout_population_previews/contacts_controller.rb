class Api::CalloutPopulationPreviews::ContactsController < Api::FilteredContactsController
  private

  def association_chain
    CalloutPopulationPreview.new(:callout_population => callout_population).contacts
  end
end
