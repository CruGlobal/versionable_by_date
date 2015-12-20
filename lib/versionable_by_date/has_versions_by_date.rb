require 'active_support'
require_relative 'version_saver'
require_relative 'version_finder'

module VersionableByDate
  module HasVersionsByDate
    extend ActiveSupport::Concern

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_versions_by_date(options)
        class_attribute :versions_by_date_model, :versions_by_date_fields,
          :versions_by_date_association

        self.versions_by_date_model = options[:with_model]
        self.versions_by_date_fields = options[:for_attributes].map(&:to_s)
        self.versions_by_date_association =
          versions_by_date_model.name.underscore.pluralize.to_sym

        has_many versions_by_date_model.name.underscore.pluralize.to_sym
        after_update { VersionSaver.new(self).save_if_needed }
        define_verisons_by_date_lookups
      end

      private

      def define_verisons_by_date_lookups
        versions_by_date_fields.each do |versioned_field|
          define_method "#{versioned_field}_on_date" do |date|
            @version_finder ||= VersionFinder.new(self)
            @version_finder.versioned_field_on(versioned_field, date)
          end
        end
      end
    end
  end
end
