# A let variable  'columns' and a variable 'custom_columns' should be defined
#
#     let(:columns) { ['Title', 'Created', ...] }
#     let(:custom_columns) { ['Description', 'Extra', ...] }
#
shared_examples "an index table" do |item_type|
  it 'displays column controls desired columns' do

    # Prime the element's text, as it is hidden by default
    find('.js-table-columns', visible: false).text(:all)

    columns.each do |column|
      expect(find('.js-table-columns', visible: false)).to have_text(column)
    end
  end

  it 'displays custom columns based on content' do
    # Prime the element's text, as it is hidden by default
    find('.js-table-columns', visible: false).text(:all)

    custom_columns.each do |column|
      expect(find('.js-table-columns', visible: false)).to have_text(column)
    end
  end
end
