# FOUND TYPES
#
# Product
# Similar Image
# Landmark
# Text
# EAN-13 Barcode
# LOGO
# QR Code
# User Submitted Result
# Print Ad
# RangerBoard

require './gogglesrequest.rb'

image_dir = 'pics/'
image_type = '.jpg'

Dir.glob(image_dir + '*' + image_type).each do |file| 
  GogglesRequest.lookup_image(file, {:file => true}).each do |r|
    printf "%-25s | %s\n", r.type, r.message
  end
end
