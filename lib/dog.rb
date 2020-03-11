class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(attributes)
    Dog.new(name: attributes[:name], breed: attributes[:breed]).save
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end
  
  def self.find_by_id(id)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0])
  end
  
  def self.find_by_name(name)
    self.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
  end

  def self.find_or_create_by(attributes)
    finder = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attributes[:name], attributes[:breed])
    finder.empty? ? self.create(attributes) : self.new_from_db(finder[0])
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    self
  end

end