require 'griddler'
require 'griddler/sendigma/version'
require 'griddler/sendigma/adapter'

Griddler.adapter_registry.register(:sendigma, Griddler::Sendigma::Adapter)