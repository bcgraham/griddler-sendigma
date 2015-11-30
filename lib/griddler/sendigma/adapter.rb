module Griddler
  module Sendigma
    class Adapter
      def initialize(params)
        @params = {
            to: '',
            cc: '',
            from: '',
            subject: '',
            text: '',
            html: '',
            attachments: 0,
            headers: '',
            charsets: '{}',
        }.reduce(params) do |memo, kv|
          memo[kv.first] = memo[kv.first].nil? ? kv.last : memo[kv.first]
          memo
        end
      end

      def self.normalize_params(params)
        sendigma = new(params)
        sendigma.normalize_params
      end

      def normalize_params
        normalized = {attachments: attachments}
        normalized.merge! decode_params(params)

        json_keys = [:envelope, :dkim, :charsets, :'attachment-info']
        json_keys.each{|key| normalized[key] = ensure_json normalized[key] }

        extras = {
            envelope: normalized[:envelope],
            dkim: normalized[:dkim],
            sender_ip: params[:sender_ip],
            charsets: normalized[:charsets],
            SPF: normalized[:SPF],
            spam_score: params[:spam_score],
            spam_report: params[:spam_report]
        }
        normalized.merge({
            to: recipients(normalized[:to]) || [],
            cc: recipients(normalized[:cc]) || [],
            from: recipients(normalized[:from]).try(:first) || '', # griddler does not accept multiple from addresses
            charsets: params[:charsets].blank? ? '{}' : params[:charsets],
            extras: extras
        })
      end

      private

      attr_reader :params

      def attachments
        attachment_count = params.delete(:attachments).to_i
        attachment_count.times.map do |i|
          params.delete("attachment#{i + 1}".to_sym)
        end
      end

      def decode_params(encoded_params)
        encoded_params.map{|key, value| [key.to_sym, decode(value)]}.to_h
      end

      def decode(val)
        unescape val unless val.nil?
      end

      def unescape(val)
        val.respond_to?(:gsub) ? val.gsub(/\\"/, '"').gsub(/\\n/, "\n") : val
      end

      def ensure_json(val)
        return {} if val.nil?
        begin
          Hash[JSON.parse(val).map{|key, value| [key.to_sym, value]}]
        rescue JSON::ParserError
          {}
        end
      end

      def recipients(field)
        # match commas not enclosed by quotes
        # http://stackoverflow.com/a/11503678
        field.split(/,(?=(?:(?:\\.|[^"\\])*"(?:\\.|[^"\\])*")*(?:\\.|[^"\\])*\Z)/).map(&:strip) unless field.nil?
      end
    end
  end
end