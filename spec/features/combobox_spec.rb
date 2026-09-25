require 'rails_helper'

describe 'Combobox' do
  before do
    login_to_project_as_user
  end

  describe 'validation errors', :js do
    before do
      visit project_issues_path(current_project)

      execute_script(<<~JS)
        const $wrapper = $(
          '<div data-behavior="combobox-spec">' +
            '<select class="form-select #{select_class}"><option value="">Pick one</option></select>' +
            '<div class="invalid-feedback">Assignee can\\'t be blank</div>' +
          '</div>'
        );
        $('body').append($wrapper);
        window.initBehaviors($wrapper[0]);
      JS
    end

    context 'when the select is rendered invalid' do
      let(:select_class) { 'is-invalid' }

      it 'shows the invalid feedback of the wrapped select' do
        within('[data-behavior~=combobox-spec]') do
          expect(page).to have_css('.combobox-container.is-invalid .combobox.is-invalid')
          expect(page).to have_text("Assignee can't be blank")
        end
      end

      it 'hides the invalid feedback when the select becomes valid' do
        execute_script("$('[data-behavior~=combobox-spec] select').removeClass('is-invalid')")

        within('[data-behavior~=combobox-spec]') do
          expect(page).to have_no_css('.is-invalid')
          expect(page).to have_no_text("Assignee can't be blank")
        end
      end
    end

    context 'when the select becomes invalid after load' do
      let(:select_class) { '' }

      it 'shows the invalid feedback' do
        within('[data-behavior~=combobox-spec]') do
          expect(page).to have_no_text("Assignee can't be blank")
        end

        execute_script("$('[data-behavior~=combobox-spec] select').addClass('is-invalid')")

        within('[data-behavior~=combobox-spec]') do
          expect(page).to have_css('.combobox-container.is-invalid .combobox.is-invalid')
          expect(page).to have_text("Assignee can't be blank")
        end
      end
    end
  end
end
