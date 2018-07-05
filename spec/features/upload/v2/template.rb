require 'rails_helper'

describe 'restoring comments' do
  before { login_to_project_as_user }

  context 'template with comments' do
    before do
      visit upload_path
    end

    it "transforms methodologies into boards", js: true do
      select "Dradis::Plugins::Projects::Upload::Template"
      attach_file \
        "file",
        Rails.root.join(
          "spec", "fixtures", "files", "templates", "with_comments.xml"
        )

      expect(page).to have_text("Worker process completed", wait: 120)

      expect(Comment.count).to eq 1
      expect(Comment.last.content).to eq 'Hello World'
    end
  end
end
