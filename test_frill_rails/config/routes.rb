TestFrillRails::Application.routes.draw do
  root to: "home#index"

  match "associations" => "home#associations", as: "associations"

  match "auto_frill" => "auto_frill#index", as: "auto_frill"
end
