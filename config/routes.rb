Rails.application.routes.draw do
  root "investments#index"
  post "/investment", to: "investments#calculate"
end
