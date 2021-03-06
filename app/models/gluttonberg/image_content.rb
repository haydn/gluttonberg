module Gluttonberg
  class ImageContent  < ActiveRecord::Base
    include Content::Block
    self.table_name = "gb_image_contents"
    belongs_to :asset, :class_name => "Gluttonberg::Asset"
    attr_accessible :asset_id, :section_name
    is_versioned

  end
end