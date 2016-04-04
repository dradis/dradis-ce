require 'spec_helper'

describe "Export Manager" do
  before { login_to_project_as_user }

  it "presents the name of the project you are exporting" do
    visit url_for({:controller => :export, :action => :index})
    page.should have_content(@project.name)
  end

  it "presents existing Issues" do
    pending "For the time being we won't show the Issues in the Export Manager"
    # @issuelib = @project.nodes.create(:label => 'All issues', :type_id => Node::Types::ISSUELIB)
    # issue = create(:issue, :node => @issuelib)
    #
    # visit url_for({:controller => :export, :action => :index})
    # page.should have_content(issue.title)
  end

  context "export plugin selection" do
    it "presents a list of available export plugins to choose from" do
      visit url_for({:controller => :export, :action => :index})

      Dradis::Plugins::with_feature(:export).each do |engine|
        page.should have_content(engine.plugin_name.to_s)
      end
    end

    it "presents a list of a available templates (if it applies)"
  end

  context "a template is passed to the export action" do
    module FakeExport
      module Actions
        def fake
          render :text => params.to_yaml
        end
      end
    end
    ExportController.class_eval %( include FakeExport::Actions )

    pending "discards invalid templates (not in the plugin's template folder)" do
      visit url_for({:controller => :export, :action => :fake, :template => 'foobar'})

      # The dummy Export plugin returns a YAML representation of every parameter
      # that it receives. The ExportController should catch the rogue :template
      # parameter and delete it before passing it along
      page.should_not have_content('foobar')
    end


    pending "allows through valid templates" do
      tmp_reports = Pathname.new('tmp/templates/reports')
      FileUtils.mkdir_p(tmp_reports)
      allow(Configuration).to receive(:paths_templates_reports).and_return(tmp_reports)

      FileUtils.mkdir(tmp_reports.join('fake_export'))
      FileUtils.touch(tmp_reports.join('fake_export/valid_template'))

      visit url_for({:controller => :export, :action => :fake, :template => 'valid_template'})

      # The dummy Export plugin returns a YAML representation of every parameter
      # that it receives. The ExportController should detect the valid :template
      # parameter and passing it along to the plugin
      page.should have_content('valid_template')

      FileUtils.rm_rf('tmp/templates/')
    end
  end
end
