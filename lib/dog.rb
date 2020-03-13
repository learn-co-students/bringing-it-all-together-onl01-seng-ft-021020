require 'pry'
class Dog 
  attr_accessor :breed, :id, :name
  
  
  def initialize (id: nil, name:,  breed:)
    @name = name 
    @breed = breed
  end 
  
  def self.create_table
    sql = <<-SQL 
      CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, 
      name TEXT, 
      breed TEXT)
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = <<-SQL 
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end 
  
  
  def self.new_from_db (row)
    new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    new_dog.id= row[0]
    new_dog
  end 
  
  def self.find_by_name(name)
    sql = <<-SQL 
      SELECT * FROM dogs
      WHERE name = ?
      
    SQL
    
    DB[:conn].execute(sql, name).map do |row|
      # binding.pry 
      self.new_from_db(row)
    end.first
    
    
  end
  
  
  def update 
    sql = <<-SQL 
      UPDATE dogs SET name = ?, breed = ?
      WHERE id = ?
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save
    if self.id 
      self.update
    else 
      sql = <<-SQL 
        INSERT INTO dogs (name, breed)
        VALUES(?,?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.breed)
      
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      
      self 
  end 
  
end 

def self.create(hash)
  new_dog = self.new(hash)
  new_dog.save
  new_dog
end 

def self.find_by_id(id)
  sql = <<-SQL
    SELECT * FROM dogs 
    WHERE id = ?
  SQL
  
  DB[:conn].execute(sql , id).map do |row|
    # binding.pry
    self.new_from_db(row)
  end.first 
end 

def self.find_or_create_by(name:, breed:)
  sql = <<-SQL 
    SELECT * FROM dogs 
    WHERE name = ? AND breed = ?
    
  SQL
  # binding.pry
  dogs = DB[:conn].execute(sql, name, breed)
  
  if !dogs.empty?
    dog_data = dogs[0]
    new_dogs = self.new_from_db(dog_data)
  
  else 
    new_dogs = self.create({:name => name, :breed => breed})
  end 
  # binding.pry
  new_dogs

end 

end 