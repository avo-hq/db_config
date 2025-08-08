# This controller has been generated to enable Rails' resource routes.
# More information on https://docs.avohq.io/3.0/controllers.html
class Avo::DbConfigsController < Avo::ResourcesController
  def after_create_path
    edit_resource_path(record: @record, resource: @resource)
  end
end
