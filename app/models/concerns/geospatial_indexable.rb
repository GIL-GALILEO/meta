module GeospatialIndexable
  extend ActiveSupport::Concern

  def has_coordinates?
    dcterms_spatial.each do |s|
      return true if element_has_coordinates s
    end
    false
  end

  def geojson
    %|{"type":"Feature","geometry":{"type":"Point","coordinates":[#{coordinates(true)}]},"properties":{"placename":"#{placename}"}}|
  end

  def multiple_geojson
    multiple_geojson_objects = []
    multiple_coordinates(true).each_with_index do |c, i|
      multiple_geojson_objects << %|{"type":"Feature","geometry":{"type":"Point","coordinates":[#{c}]},"properties":{"placename":"#{multiple_placename[i]}"}}|
    end
    multiple_geojson_objects
  end

  def placename
    return 'No Location Information Available' unless dcterms_spatial.first and dcterms_spatial.first.is_a? String
    placename = dcterms_spatial.first.gsub(coordinates_regex, '')
    return placename.chop.chop if element_has_coordinates dcterms_spatial.first
    placename
  end

  def multiple_placename
    # return ['No Location Information Available'] unless dcterms_spatial.first and dcterms_spatial.first.is_a? String
    dcterms_spatial.map do |e|
      if e =~ coordinates_regex
        e.gsub(coordinates_regex, '').chop.chop
      else
        'No Location Information Available'
      end
    end
    # placename = dcterms_spatial.first.gsub(coordinates_regex, '')
    # return placename.chop.chop if element_has_coordinates dcterms_spatial.first
    # placename
  end

  # return first set of discovered coordinates, or a silly spot if none found
  # todo: figure out a way to not index a location for items with no coordinates
  def coordinates(alt_format = false)
    if alt_format
      return '-80.394617, 31.066399' unless has_coordinates?
      dcterms_spatial.each do |el|
        return "#{longitude(el)}, #{latitude(el)}" if element_has_coordinates el
      end
    else
      return '31.066399, -80.394617' unless has_coordinates?
      dcterms_spatial.each do |el|
        return  "#{latitude(el)}, #{longitude(el)}" if element_has_coordinates el
      end
    end
  end

  def multiple_coordinates(alt_format = false)
    coordinates_array = []
    if alt_format
      return ['-80.394617, 31.066399'] unless has_coordinates?
      dcterms_spatial.each do |el|
        coordinates_array << "#{longitude(el)}, #{latitude(el)}" if element_has_coordinates el
      end
    else
      return ['31.066399, -80.394617'] unless has_coordinates?
      dcterms_spatial.each do |el|
        coordinates_array <<  "#{latitude(el)}, #{longitude(el)}" if element_has_coordinates el
      end
    end
    coordinates_array
  end

  private


  def latitude(el)
    el.match(coordinates_regex)[1]
  end

  def longitude(el)
    el.match(coordinates_regex)[2]
  end

  def element_has_coordinates(e)
    coordinates_regex === e
  end

  def coordinates_regex
    /(-?\d+\.\d+), (-?\d+\.\d+)/
  end

end