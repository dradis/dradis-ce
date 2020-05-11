shared_examples 'collapses autosaves' do
  it 'removes autosaves', versioning: true do
    model.update(updated_at: Time.now, paper_trail_event: RevisionTracking::REVISABLE_EVENTS[:autosave])

    expect { submit_form }.to change {
      model.versions.where(event: RevisionTracking::REVISABLE_EVENTS[:autosave]).count
    }.by(-1)
  end
end
