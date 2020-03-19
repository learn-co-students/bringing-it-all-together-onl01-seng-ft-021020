class Dog 
  
  attr_accessor :id, :name, :breed 
  
  def initialize(hash)
    @name = hash[:name] 
    @id = hash[:id]
    @breed = hash[:breed]
  end
  
  def self.create_table 
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
    
  end
  
  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    
    DB[:conn].execute(sql)
    
  end

  def self.new_from_db(row)
    hash ={name: row[1], id: row[0], breed: row[2]} 
    new_dog = Dog.new(hash)
    new_dog
  
  end
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs 
      WHERE name = ?
    SQL
    
    result = DB[:conn].execute(sql,name)[0]
    Dog.new_from_db(result)
    
  end
  
  def save
    if self.id != nil
      self.update
    else 
      sql = <<-SQL 
        INSERT INTO dogs(name,breed)
        VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id =DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  def self.find_by_id(id)
    sql = <<-SQL 
      SELECT * FROM dogs 
      WHERE id = ?
    SQL
    
    result = DB[:conn].execute(sql,id)[0]
    Dog.new_from_db(result)
  end
  
  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save 
    new_dog
    
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL


    dog = DB[:conn].execute(sql, name, breed).first
    hash = {:name => name, :breed => breed}

    if dog
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create(hash)
    end
    new_dog
  end
  
end