TestFrillRails::Application.routes.draw do
  root to: "home#index"

  match "associations" => "home#associations", as: "associations"
end
