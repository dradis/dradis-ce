require_relative "../../../lib/text-processing/markup_fields"

describe MarkupFields do
    describe MarkupFields::Field do
    end

    subject { MarkupFields.new('') }

    context 'before initialization' do
        it 'has a constructor that accepts 1 argument' do
            expect(MarkupFields).to respond_to(:new).with(1).argument
        end
    end

    context 'when successfully initialized' do
        it 'has an interface that responds to messages' do
            expect(subject).to respond_to(:fields)
        end

        describe '#fields' do
            it 'matches final field when line ends in newline'
            it 'matches final field when line ends in end of string'
            it 'matches final field when match is between #[ and #]'
            it 'matches two fields on one line'
            it 'matches two fields on separate lines'
            it 'returns an array when one match is present'
        end
    end
end
