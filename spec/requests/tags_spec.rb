require 'rails_helper'

describe "tag requests" do
  let(:tag) { Tag.create!(name: tag_name) }
  let(:tag_name) { 'tag_name' }
  let(:new_tag_name) { 'new_tag_name' }

  before do
    @project = Project.new
    # login as admin
    Configuration.create(name: 'admin:password', value: ::BCrypt::Password.create('rspec_pass'))
    @user = create(:user, :admin)
    post session_path, params: { login: @user.email, password: 'rspec_pass' }
  end

  describe "POST #create" do
    let(:send_request) do
      post project_tags_path(@project), params: { tag: { name: tag_name } }
    end

    it "creates a tag" do
      expect { send_request }.to change { Tag.count }.by(1)
      expect(Tag.last.name).to eq(tag_name)
    end
  end

  describe "PATCH #update" do
    let(:send_request) do
      patch project_tag_path(@project, tag), params: { tag: { name: new_tag_name } }
    end

    it "updates a tag" do
      tag # create tag
      expect { send_request }.not_to change { Tag.count }
      expect(Tag.last.name).to eq(new_tag_name)
    end
  end

  describe "DELETE #update" do
    let(:send_request) do
      delete project_tag_path(@project, tag), params: { project_id: @project.id, id: tag.id }
    end

    it "deletes a tag" do
      tag # create tag
      expect { send_request }.to change { Tag.count }.by(-1)
    end
  end
end
