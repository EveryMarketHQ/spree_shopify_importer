module Spree
  module Admin
    class ShopifyImporterSettingsController < ResourceController
      def update
        settings = Spree::ShopifyImporterSetting.new
        preferences = params && params.key?(:preferences) ? params.delete(:preferences) : params
        preferences.each do |name, value|
          next unless settings.has_preference? name.to_param
          settings[name] = value
        end
        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:shopify_importer_settings, scope: :shopify_importer))
        redirect_to edit_admin_shopify_importer_settings_path
      end
    end
  end
end