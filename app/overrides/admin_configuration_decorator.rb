Deface::Override.new(
  virtual_path:  'spree/admin/shared/sub_menu/_configuration',
  name:          'add_shopify_importer_to_configurations_menu',
  insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
  text:          '<%= configurations_sidebar_menu_item Spree.t(:shopify_importer_settings, scope: :shopify_importer), edit_admin_shopify_importer_settings_path %>'
)