require 'spec_helper'

describe Griddler::Sendigma do
  it 'has a version number' do
    expect(Griddler::Sendigma::VERSION).not_to be nil
  end
end


describe Griddler::Sendigma::Adapter, '.normalize_params' do
  def normalize_params(params)
    Griddler::Sendigma::Adapter.normalize_params(params)
  end

  it_should_behave_like 'Griddler adapter',
                        :sendigma,
                        ActionController::Parameters.new({
                            text: 'hi',
                            to: 'Hello World <hi@example.com>',
                            cc: 'emily@example.com',
                            from: 'There <there@example.com>'
                        })
  it 'has no attachments' do
    params = default_params

    normalized_params = normalize_params(params)
    expect(normalized_params[:attachments]).to be_empty
  end

  shared_examples 'multiple-address field' do |field|
    context 'when key is absent, nil, or blank' do
      it 'is empty array' do
        expect(normalize_params(default_params)[field]).to be_a Array
        expect(normalize_params(default_params)[field]).to be_empty
        expect(normalize_params(default_params(with: {field => nil}))[field]).to be_a Array
        expect(normalize_params(default_params(with: {field => nil}))[field]).to be_empty
        expect(normalize_params(default_params(with: {field => ''}))[field]).to be_a Array
        expect(normalize_params(default_params(with: {field => ''}))[field]).to be_empty
      end
    end

    context 'given one address' do
      shared_examples 'one address' do |input, address|
        let (:normalized) { normalize_params(default_params(with: {field => input}))[field] }

        it 'is one-element array' do
          expect(normalized).to be_a Array
          expect(normalized.size).to eq(1)
        end
        it 'contains the email address' do
          expect(normalized).to include(address)
        end
      end
      it_behaves_like 'one address', 'Bob <bob@example.com>', 'Bob <bob@example.com>'
      context 'with quotes' do
        it_behaves_like 'one address', '\"Bob\" <bob@example.com>', '"Bob" <bob@example.com>'
      end
      context 'with commas in quotes' do
        it_behaves_like 'one address', '\"Bob, Jr.\" <bobjr@example.com>', '"Bob, Jr." <bobjr@example.com>'
      end
      context 'with comma and escaped quotes' do
        it_behaves_like 'one address', '\"Alice \\\"Like, The Real Deal\\\" Jones\" <alicejones@example.com>', '"Alice \"Like, The Real Deal\" Jones" <alicejones@example.com>'
      end
    end

    context 'given two addresses' do
      shared_examples 'two addresses' do |both, first, second|
        let (:normalized) { normalize_params(default_params(with: {field => both}))[field] }

        it 'is two-element array' do
          expect(normalized).to be_a Array
          expect(normalized.size).to eq(2)
        end

        it 'contains both addresses' do
          expect(normalized).to include(first)
          expect(normalized).to include(second)
        end
      end

      it_behaves_like 'two addresses', 'Bob <bob@example.com>, Carol <carol@example.com>', 'Bob <bob@example.com>', 'Carol <carol@example.com>'
      it_behaves_like 'two addresses', '\"Bob\" <bob@example.com>, \"Carol\" <carol@example.com>','"Bob" <bob@example.com>', '"Carol" <carol@example.com>'
      it_behaves_like 'two addresses', '\"Bob, Jr.\" <bob@example.com>, \"Carol, Jr.\" <carol@example.com>', '"Bob, Jr." <bob@example.com>', '"Carol, Jr." <carol@example.com>'
      it_behaves_like 'two addresses', '\"Bob \\\"Like, The Real Deal\\\", Jr.\" <bob@example.com>, \"Carol \\\"Like, The Realer Deal\\\", Jr.\" <carol@example.com>', '"Bob \"Like, The Real Deal\", Jr." <bob@example.com>', '"Carol \"Like, The Realer Deal\", Jr." <carol@example.com>'
    end
  end

  shared_examples 'scalar text field' do |field|
    context 'when key is absent or nil' do
      it 'is empty string' do
        expect(normalize_params(ActionController::Parameters.new)[field]).to eq('')
        expect(normalize_params(default_params(with: {field => nil}))[field]).to eq('')
      end
    end
    context 'given value' do
      let(:normalized) { normalize_params(default_params(with: {field => 'a value'}))[field]}
      it 'is the value' do
        expect(normalized).to eq('a value')
      end
    end
  end
  shared_examples 'nil-able scalar text field' do |field|
    context 'when key is absent or nil' do
      it 'is empty string' do
        expect(normalize_params(ActionController::Parameters.new)[:extras][field]).to eq(nil)
        expect(normalize_params(default_params(with: {field => nil}))[:extras][field]).to eq(nil)
      end
    end
    context 'given value' do
      let(:normalized) { normalize_params(default_params(with: {field => 'a value'}))[:extras][field]}
      it 'is the value' do
        expect(normalized).to eq('a value')
      end
    end
  end

  shared_examples 'json field' do |field|
    context 'when key is absent or nil' do
      it 'is empty hash' do
        expect(normalize_params(ActionController::Parameters.new)[:extras][field]).to be_a Hash
        expect(normalize_params(ActionController::Parameters.new)[:extras][field]).to be_empty
        expect(normalize_params(default_params(with: {field => nil}))[:extras][field]).to be_a Hash
        expect(normalize_params(default_params(with: {field => nil}))[:extras][field]).to be_empty
      end
    end
    context 'given malformed json' do
      let(:normalized) { normalize_params(default_params(with: {field => '{"key1": 1}, "key2": 2}'}))[:extras][field]}
      it 'is an empty hash' do
        expect(normalized).to be_a Hash
        expect(normalized).to be_empty
      end
    end
    context 'given valid json' do
      let(:normalized) { normalize_params(default_params(with: {field => '{"to": ["bob@example.com", "carol@example.com"], "from": ["alice@example.com"]}'}))[:extras][field]}
      it 'is a non-empty hash' do
        expect(normalized).to be_a Hash
        expect(normalized).not_to be_empty
      end
    end
  end

  describe '[:to]' do
    it_behaves_like 'multiple-address field', :to
  end

  describe '[:cc]' do
    it_behaves_like 'multiple-address field', :cc
  end

  describe '[:from]' do
    it_behaves_like 'scalar text field', :from
  end
  describe '[:subject]' do
    it_behaves_like 'scalar text field', :subject
  end
  describe '[:text]' do
    it_behaves_like 'scalar text field', :text
  end
  describe '[:html]' do
    it_behaves_like 'scalar text field', :html
  end
  describe '[:attachments]' do
    context 'with no attachments' do
      it 'is empty array when no attachments are given' do
        expect(normalize_params(default_params)[:attachments]).to be_a Array
        expect(normalize_params(default_params)[:attachments]).to be_empty
      end
    end
    context 'with one attachment' do
      let(:normalized) { normalize_params(default_params(with: attachments(1)))[:attachments] }
      it 'is one-element array' do
        expect(normalized).to be_a Array
        expect(normalized.size).to eq(1)
      end

      it 'includes a ActionDispatch::Http::UploadedFile' do
        expect(normalized.first).to be_a ActionDispatch::Http::UploadedFile
      end
    end
    context 'with two attachments' do
      let(:normalized) { normalize_params(default_params(with: attachments(2)))[:attachments] }
      it 'is two-element array' do
        expect(normalized).to be_a Array
        expect(normalized.size).to eq(2)
      end

      it 'includes two ActionDispatch::Http::UploadedFile' do
        expect(normalized.first).to be_a ActionDispatch::Http::UploadedFile
        expect(normalized.second).to be_a ActionDispatch::Http::UploadedFile
      end
    end
  end

  describe '[:headers]' do
    it_behaves_like 'scalar text field', :headers
  end
  describe '[:charsets]' do
    context 'when key is absent or nil' do
      it 'is empty JSON string' do
        expect(normalize_params(ActionController::Parameters.new)[:charsets]).to eq('{}')
        expect(normalize_params(default_params(with: {:charsets => nil}))[:charsets]).to eq('{}')
      end
    end
    context 'given value' do
      let(:normalized) { normalize_params(default_params(with: {:charsets => 'a value'}))[:charsets]}
      it 'is the value' do
        expect(normalized).to eq('a value')
      end
    end
  end
  describe '[:extras]' do
    describe '[:envelope]' do
      it_behaves_like 'json field', :envelope
    end
    describe '[:dkim]' do
      it_behaves_like 'json field', :dkim
    end
    describe '[:sender_ip]' do
      it_behaves_like 'nil-able scalar text field', :sender_ip
    end
    describe '[:charsets]' do
      it_behaves_like 'json field', :charsets
    end
    describe '[:SPF]' do
      it_behaves_like 'nil-able scalar text field', :SPF
    end
    describe '[:spam_score]' do
      it_behaves_like 'nil-able scalar text field', :spam_score
    end
    describe '[:spam_report]' do
      it_behaves_like 'nil-able scalar text field', :spam_report
    end
  end

  def default_params(plus:{},with:{})
    plus.reduce(basic_params) do |memo, v|
      memo[v.first] = [memo[v.first], v.second].flatten.compact.join(', ')
      memo
    end.merge with
  end

  def basic_params
    ActionController::Parameters.new(from: 'Alice <alice@example.com>')
  end

  def attachments(number=0)
    number.times.reduce([[:attachments, number]]) {|memo, i| memo << ["attachment#{i+1}", attachment("#{i+1}.jpg")]}.to_h
  end

  def attachment(name=nil)
    ActionDispatch::Http::UploadedFile.new(
        {
            filename: name || 'edward_nigma.jpg',
            type: 'image/jpg',
            tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/../../fixtures/edward_nigma.jpg")
        })
  end
  def attachment(name=nil)
    ActionDispatch::Http::UploadedFile.new(tempfile: File.new("/tmp/tmpfile", 'w'))
  end

end
