require 'rails_helper'

describe 'Issue tab memory', js: true do
  before { login_to_project_as_user }

  let(:record) { create(:issue, node: current_project.issue_library) }
  let(:other_record) { create(:issue, node: current_project.issue_library) }
  let(:record_path) { project_issue_path(current_project, record) }
  let(:other_record_path) { project_issue_path(current_project, other_record) }
  let(:default_tab) { '#info-tab' }
  let(:other_tab) { '#evidence-tab' }
  let(:strip) { '[data-controller~="tab-memory"]' }
  let(:storage_key) { "dradis:tab-memory:#{ActionView::RecordIdentifier.dom_id(record)}" }

  def expect_active_tab(target)
    expect(page).to have_css("#{strip} [href='#{target}'][aria-selected='true']")
    expect(page).to have_css("#{target}.active", visible: true)
  end

  def select_tab(target)
    find("#{strip} [href='#{target}']").click
    expect_active_tab(target)
  end

  it 'remembers the selected tab on a fresh visit and isolates other records' do
    visit record_path
    select_tab(other_tab)

    visit other_record_path
    expect_active_tab(default_tab)

    visit record_path
    expect_active_tab(other_tab)
  end

  it 'gives an explicit URL precedence and remembers it even when already active' do
    visit record_path
    select_tab(other_tab)

    visit "#{record_path}?tab=#{default_tab.delete_prefix('#')}"
    expect_active_tab(default_tab)

    visit record_path
    expect_active_tab(default_tab)
  end

  it 'falls back from an unknown URL tab to the remembered tab' do
    visit record_path
    select_tab(other_tab)

    visit "#{record_path}?tab=removed-addon"
    expect_active_tab(other_tab)
  end

  it 'uses the default when a remembered addon tab no longer exists' do
    visit record_path
    page.execute_script('localStorage.setItem(arguments[0], "#removed-addon")', storage_key)

    visit record_path
    expect_active_tab(default_tab)
  end

  it 'remembers an override without changing the tab the user opens' do
    visit record_path
    page.execute_script(<<~JS, strip, other_tab, default_tab)
      const tabs = document.querySelector(arguments[0]);
      const tab = Array.from(tabs.querySelectorAll('[data-bs-toggle="tab"]'))
        .find((element) => element.getAttribute('href') === arguments[1]);
      tab.dataset.tabMemoryRestore = arguments[2];
    JS
    select_tab(other_tab)

    visit record_path
    expect_active_tab(default_tab)
  end

  it 'remembers an override before following a calculator-style navigation link' do
    visit record_path
    select_tab(other_tab)
    page.execute_script(<<~JS, strip, record_path, default_tab)
      const link = document.createElement('a');
      link.href = arguments[1];
      link.textContent = 'Calculator return';
      link.dataset.tabMemoryRestore = arguments[2];
      document.querySelector(arguments[0]).append(link);
    JS

    click_link 'Calculator return'
    expect_active_tab(default_tab)
  end

  it 'preserves other query parameters and replaces history when restoring' do
    # A fresh window avoids the browser's history cap after a long feature suite.
    window = open_new_window
    within_window(window) do
      visit record_path
      select_tab(other_tab)
      previous_length = page.evaluate_script('history.length')

      visit "#{record_path}?context=testing"
      expect_active_tab(other_tab)
      expect(page).to have_current_path("#{record_path}?context=testing&tab=#{other_tab.delete_prefix('#')}")
      expect(page.evaluate_script('history.length')).to eq(previous_length + 1)

      select_tab(default_tab)
      expect(page.evaluate_script('history.length')).to eq(previous_length + 2)
      expect(page).to have_current_path("#{record_path}?context=testing&tab=#{default_tab.delete_prefix('#')}")
    end
  ensure
    window&.close
  end

  it 'continues to switch tabs when localStorage is blocked' do
    visit record_path
    page.execute_script(<<~JS)
      Storage.prototype.setItem = () => { throw new DOMException('Blocked', 'SecurityError'); };
    JS
    select_tab(other_tab)
    expect(page).to have_current_path("#{record_path}?tab=#{other_tab.delete_prefix('#')}")
  end

  it 'does not remember a tab change that an addon cancels' do
    visit record_path
    page.execute_script(<<~JS, strip)
      document.querySelector(arguments[0]).addEventListener('show.bs.tab', (event) => event.preventDefault());
    JS
    find("#{strip} [href='#{other_tab}']").click
    expect_active_tab(default_tab)

    visit record_path
    expect_active_tab(default_tab)
  end
  it 'remembers addon tabs without additional markup' do
    visit record_path
    find('[data-bs-toggle="tab"][href="#echo-tab"]').click
    expect(page).to have_css('#echo-tab.active')

    visit record_path
    expect(page).to have_css('#echo-tab.active')
  end
end
