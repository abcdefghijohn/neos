require 'figaro'

Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load
