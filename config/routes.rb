Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :admin do
    resource :shopify_importer_settings, only: [:edit, :update]
  end
end
