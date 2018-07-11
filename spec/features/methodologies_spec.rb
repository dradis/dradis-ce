require 'rails_helper'

describe "Describe methodologies" do
  it "should require authenticated users" do
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    visit project_methodologies_path(project_id: 1)
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  describe "as authenticated user" do

    before { login_to_project_as_user }
    let(:methodology_library){ Node.methodology_library }

    it "shows a 'No methodologies assigned' message if none have been assigned" do
      methodology_library.notes.destroy_all
      visit project_methodologies_path(@project)
      expect(current_path).to eq(project_methodologies_path(@project))
      expect(page).to have_content('No methodologies')
    end

    it "presents a list of assigned methodologies" do
      list = [ 'Tiesto', 'Skrillex', 'Swedish House Mafia' ]
      list.each do |name|
        methodology_library.notes.create!(category: Category.default, author: 'rspec', text: "<methodology><name>#{name}</name></methodology>" )
      end

      visit project_methodologies_path(@project)
      expect(current_path).to eq(project_methodologies_path(@project))
      list.each do |name|
        expect(page).to have_content(name)
      end
    end

    it "presents sections and tasks for each methodology" do
      list = []
      ['methodologies/webapp.xml'].each do |file|
        xml_blob = File.read(Rails.root.join('spec/fixtures/files', file))
        methodology_library.notes.create(category: Category.default, author: 'rspec', text: xml_blob )
        list << Methodology.new(content: xml_blob )
      end

      visit project_methodologies_path(@project)
      expect(current_path).to eq(project_methodologies_path(@project))

      list.each do |checklist|
        checklist.sections.each do |section|
          expect(page).to have_content(section.name)
          section.tasks.each do |task|
            expect(page).to have_content(task.name)
          end
        end
      end
    end

    it "presents checked/unchecked boxes depending on the 'checked' attribute of the <task>" do
      doc = Nokogiri::XML(File.read(Rails.root.join('spec/fixtures/files/methodologies/webapp.xml')))

      doc.xpath('//task')[1].set_attribute('checked', 'checked')
      doc.xpath('//task')[2].set_attribute('checked', '')

      methodology_library.notes.create(category: Category.default, author: 'rspec', text: doc.to_s)

      visit project_methodologies_path(@project)
      expect(current_path).to eq(project_methodologies_path(@project))

      expect(page).to have_content('Reconnaissance')
      expect(page).to have_xpath("//input[@checked and @name='Authentication~Maximal crazy']")
      expect(page).to have_xpath("//input[@checked and @name='Authentication~Miami 2 Ibiza']")
    end

    pending "changes the task status in sync with the checkbox in the UI", js: true do
      methodology = Methodology.from_file(Rails.root.join('spec/fixtures/files/methodologies/webapp.xml'))
      note = methodology_library.notes.create(category: Category.default, author: 'rspec', text: methodology.content )

      visit project_methodologies_path(@proejct)
      expect(current_path).to eq(project_methodologies_path(@project))

      find('#Reconnaissance_Say_a_little_something').set(true)

      begin
        wait_until { page.find('.saved') }
        note = Note.last.reload
        doc = Nokogiri::XML(note.text)
        expect(doc.xpath("//task[@checked and text()='Say a little something']")).to_not be_empty()
      rescue Capybara::TimeoutError
        flunk "Failed at waiting for loading spinner to appear."
      end
    end

    pending "presents a link to remove existing methodologies" do
      list = []
      ['methodologies/webapp.xml'].each do |file|
        file_path = Rails.root.join('spec/fixtures/files', file)
        xml_blob = File.read(file_path)
        note = methodology_library.notes.create(category: Category.default, author: 'rspec', text: xml_blob )
        list << Methodology.new(filename: note.id, content: xml_blob)
      end

      visit project_methodologies_path(@project)
      list.each do |checklist|
        expect(page).to have_xpath("//a",href: project_methodology_path(@project, checklist), data_method: 'delete')
      end
    end

    context "there are some methodology templates" do
      before(:each) do
        allow(Methodology).to receive(:pwd).and_return(Rails.root.join('tmp/templates/methodologies'))
        FileUtils.mkdir_p(Methodology.pwd) unless File.exists?(Methodology.pwd)
        @available = []
        Dir[Rails.root.join('spec/fixtures/files/methodologies/**.xml')].collect do |file|
          FileUtils.cp(file, Methodology.pwd.join(File.basename(file)))
          @available << file
        end
      end
      after(:all) do
        FileUtils.rm_rf('tmp/templates')
      end

      it "presents a list to add methodologies (with all the available ones)" do
        visit project_methodologies_path(@project)
        @available.each do |file|
          expect(page).to have_link(Methodology.from_file(file).name)
        end
      end

      it "lets your choose the name you want to use when adding a new methodology" do
        methodology = Methodology.from_file(@available.first)
        visit add_project_methodology_path(@project, methodology)
        expect(page).to have_field('Name', with: methodology.name)

        methodology_library.notes.destroy_all

        fill_in 'Name', with: 'RSPec methodology'
        click_button 'Add to project'

        expect(methodology_library.reload.notes.count).to eq(1)
        expect(current_path).to eq(project_methodologies_path(@project))
        expect(page).to have_content('RSPec methodology')
      end
    end
  end
end
