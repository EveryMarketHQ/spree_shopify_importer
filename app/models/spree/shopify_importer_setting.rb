module Spree
  class ShopifyImporterSetting < Preferences::Configuration
    preference :shopify_api_key, :string
    preference :shopify_password, :string
    preference :shopify_shop_domain, :string
    preference :shopify_api_version, :string, default: '2020-01'
    preference :shopify_token, :string
    preference :shopify_rescue_limit, :integer, default: 5
    preference :shopify_current_credentials, :hash
    preference :shopify_import_queue, :string, default: 'default'
  end
end