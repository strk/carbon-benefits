class Polygon
  include ActiveRecord::AttributeAssignment

  #TABLENAME = :polygon
  TABLENAME = :polygon_test

  #Model to access cartodb's polygons
  ATTRIBUTES = [ :cartodb_id, :name, :the_geom, :class_id, :layer_id ]
  ATTRIBUTES.each do |attr| attr_accessor attr end

  def initialize attributes = nil
    assign_attributes(attributes, :without_protection => true) if attributes
  end

  #Inserts a polygon into CartoDB
  def save
    if cartodb_id
      update
    else
      self.the_geom = Polygon.gmaps_path_to_wkt(self.the_geom)
      #puts self.the_geom
      #response = CartoDB::Connection.insert_row(TABLENAME, attributes.delete_if{|k,v| k == :cartodb_id})
      sql = <<-SQL
        INSERT INTO #{TABLENAME} (the_geom, name, class_id, layer_id) VALUES (#{self.the_geom}, '#{self.name}', #{self.class_id||"NULL"}, #{self.layer_id||"NULL"})
      SQL
      puts sql
      response = CartoDB::Connection.query(sql)
      cartodb_id = response[:cartodb_id]
      self
    end
  end

  #Updates a record in CartoDB
  def update
    CartoDB::Connection.update_row(TABLENAME, cartodb_id, attributes.delete_if{|k,v| k == :cartodb_id})
    self
  end

  def attributes
    Hash[ATTRIBUTES.map{ |attr|
      [attr,send(attr)]
    }]
  end

  # Build a new object using the params from backbone
  #
  # @param [Hash] params posted from backbone, slightly denormalised attributes
  # @return [Polygon] the newly built polygon
  def self.new_from_params params
    class_name = params.delete(:class)
    params[:class_id] = PolygonClass.find_or_create_by_name(class_name).id

    Polygon.new(params)
  end

  # Translates a google maps path to WKT, suitable for inserting
  # into postgis
  #
  # @params [String] path the path to translate
  # @return [String] Geojson string
  def self.gmaps_path_to_wkt path
    coordinates = []
    path.each do |coordinate|
      coordinates << "#{coordinate[1]} #{coordinate[0]}"
    end
    coordinates << "#{path[0][1]} #{path[0][0]}" # Close the polygon

    "ST_GeomFromText('MULTIPOLYGON(((#{coordinates.join(',')})))', 4326)"
  end

  def self.find cartodb_id
    new(CartoDB::Connection.row(TABLENAME, cartodb_id))
  end

  def self.create_or_update_from attributes, layer_id
    if attributes[:cartodb_id].nil?
      polygon = self.new(attributes)
      polygon.layer_id = layer_id
      polygon.save
    else
      polygon = self.find(attributes[:cartodb_id])
      if polygon && polygon.layer_id == self.id
        polygon.name = attributes[:name]
        polygon.the_geom = attributes[:the_geom]
        polygon.class_id = attributes[:class_id]
        polygon.update
      end
    end
  end
end
